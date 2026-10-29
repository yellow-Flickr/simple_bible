#!/usr/bin/env python3
"""Prints the reflection-writing prompt, ready to paste into an LLM.

With no options it prints the template as it is (it already contains style
samples and 10 starter topics), so it only needs the template file.

To get other topics, it swaps in a fresh set of topics and candidate passages:
  python3 build_reflection_prompt.py --topics love,prayer
  python3 build_reflection_prompt.py --count 10

It looks for the files it needs (the template, topics.json, kjv.json and,
optionally, reflections.json) near where you run it and asks for the path if it
can't find them, so it does not depend on any project layout.

Rules built in: at most 10 topics per prompt and 3 reflections per topic, and a
different set of candidate passages on every run (the seed used is printed so a
run can be repeated with --seed).
"""
import argparse, json, os, random, re, sys, time
from pathlib import Path

START, END = '<!-- TOPICS:START -->', '<!-- TOPICS:END -->'
MAX_TOPICS, PER_TOPIC = 10, 3
SKIP_DIRS = {'build', 'node_modules', '__pycache__', 'Pods'}
BOOK_ALIAS = {'psalm': 'Psalms', 'acts': 'Acts of the Apostles', 'song of songs': 'Song of Solomon'}


def say(msg):
    print(msg, file=sys.stderr)


def ask(question):
    if not sys.stdin.isatty():
        raise SystemExit(f'{question}\n(not running interactively; pass the path as an option instead)')
    say(question)
    return input('> ').strip().strip('"').strip("'")


def search_stages():
    """Places to look, nearest first: (folder, how many levels down to search)."""
    here = Path.cwd()
    script = Path(__file__).resolve().parent
    stages = [(here, 3), (script, 3)]
    for base in (here, script):
        for parent in list(base.parents)[:3]:
            stages.append((parent, 2))
    return stages


def find_all(name):
    for root, depth in search_stages():
        found = []
        for dirpath, dirs, files in os.walk(root):
            level = len(Path(dirpath).relative_to(root).parts)
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith('.')] if level < depth else []
            for f in files:
                if f.lower() == name.lower():
                    p = (Path(dirpath) / f).resolve()
                    if p not in found:
                        found.append(p)
        if found:
            return found
    return []


def resolve(name, label, given=None, optional=False):
    if given:
        p = Path(given).expanduser()
        p = p / name if p.is_dir() else p
        if not p.is_file():
            raise SystemExit(f'{label} not found at {p}')
        return p
    found = find_all(name)
    if len(found) == 1:
        say(f'Using {label}: {found[0]}')
        return found[0]
    if len(found) > 1:
        say(f'Found several files named {name}:')
        for i, p in enumerate(found, 1):
            say(f'  {i}. {p}')
        choice = ask(f'Which one is the {label}? (number, or a different path)')
        if choice.isdigit() and 1 <= int(choice) <= len(found):
            return found[int(choice) - 1]
        found = []
        given = choice
    if optional and not given and not sys.stdin.isatty():
        say(f'No {name} found; continuing without existing reflections.')
        return None
    for _ in range(3):
        hint = ' (press Enter to skip)' if optional else ''
        entry = given or ask(f'Could not find {name}. Path to the {label}, or to the folder containing it?{hint}')
        given = None
        if not entry and optional:
            return None
        p = Path(entry).expanduser()
        p = p / name if p.is_dir() else p
        if p.is_file():
            return p
        say(f'  Not found: {p}')
    raise SystemExit(f'Giving up: {label} not found.')


def load_json(path, label):
    try:
        return json.loads(Path(path).read_text(encoding='utf-8'))
    except (OSError, ValueError) as e:
        raise SystemExit(f'Could not read {label} ({path}): {e}')


def build_pack(args):
    topics_path = resolve('topics.json', 'topics file', args.topics_file)
    kjv_path = resolve('kjv.json', 'KJV Bible file', args.kjv_file)
    refl_path = resolve('reflections.json', 'existing reflections file (optional)', args.reflections_file, optional=True)

    try:
        topics = {t['slug']: t for t in load_json(topics_path, 'topics file')['topics']}
        kjv = load_json(kjv_path, 'KJV file')['version']
        names = []
        for v in kjv:
            if v['book_name'] not in names:
                names.append(v['book_name'])
        text = {(v['book_id'], v['chapter'], v['verse']): v['text'] for v in kjv}
    except (KeyError, TypeError):
        raise SystemExit('The topics or KJV file is not in the expected format '
                         '(topics: {"topics": [...]}, KJV: {"version": [...]}).')

    existing = []
    if refl_path:
        existing = load_json(refl_path, 'reflections file').get('reflections', [])
    by_topic = {}
    for r in existing:
        by_topic.setdefault(r['topic'], []).append(r)

    rng = random.Random(args.seed)
    if args.topics:
        slugs = [s.strip() for s in args.topics.split(',') if s.strip()]
        unknown = [s for s in slugs if s not in topics]
        if unknown:
            raise SystemExit(f'Unknown topics: {unknown}')
    else:
        slugs = sorted(topics, key=lambda s: (len(by_topic.get(s, [])), rng.random()))[:args.count]
    if len(slugs) > MAX_TOPICS:
        raise SystemExit(f'Too many topics ({len(slugs)}). Rule: at most {MAX_TOPICS} per prompt; '
                         'long outputs make reflections generic. Run it again for the next batch.')

    def verse_text(v):
        key = v['book'].lower()
        book = names.index(BOOK_ALIAS.get(key, v['book'])) + 1
        a, _, z = v['verses'].partition('-')
        return ' '.join(text[(book, v['chapter'], n)] for n in range(int(a), int(z or a) + 1))

    blocks = []
    for slug in slugs:
        topic = topics[slug]
        done = by_topic.get(slug, [])
        used = {(r['book'], r['chapter'], r['verses']) for r in done}
        pool = []
        for v in topic['verses']:
            if (v['book'], v['chapter'], v['verses']) in used:
                continue
            try:
                t = verse_text(v)
            except (ValueError, KeyError):
                continue  # passage not in this Bible file
            if len(t) <= args.max_chars:
                pool.append((v, t))
        rng.shuffle(pool)
        related = ', '.join(topic.get('related_topics', [])[:6]) or 'none'
        lines = [f"### {topic['name']}  (slug: {slug})",
                 f'related topics: {related}',
                 f'next_id: {slug}-{len(done) + 1:03d}']
        if done:
            lines.append('already written (do not repeat these ideas or titles):')
            lines += [f"  - \"{r['title']}\" ({r['book']} {r['chapter']}:{r['verses']})" for r in done]
        lines.append(f'candidate passages (KJV), pick {PER_TOPIC}:')
        for v, t in pool[:args.candidates]:
            lines.append(f"  - book=\"{v['book']}\" chapter={v['chapter']} verses=\"{v['verses']}\"  |  {t}")
        blocks.append('\n'.join(lines))
    return '\n\n'.join(blocks)


def main():
    ap = argparse.ArgumentParser(description='Print the reflection-writing prompt.')
    ap.add_argument('--topics', help='comma-separated topic slugs (max 10)')
    ap.add_argument('--count', type=int, help='use this many topics with the fewest reflections (max 10)')
    ap.add_argument('--candidates', type=int, default=6, help='candidate passages per topic (default 6)')
    ap.add_argument('--max-chars', type=int, default=320, help='longest verse text to offer')
    ap.add_argument('--seed', type=int, help='repeat an earlier run; default is a new seed each time')
    ap.add_argument('--pack-only', action='store_true', help='print only the topics section')
    ap.add_argument('--template')
    ap.add_argument('--topics-file')
    ap.add_argument('--kjv-file')
    ap.add_argument('--reflections-file')
    args = ap.parse_args()

    chosen = len([t for t in (args.topics or '').split(',') if t.strip()])
    for n in (chosen, args.count or 0):
        if n > MAX_TOPICS:
            raise SystemExit(f'Too many topics ({n}). Rule: at most {MAX_TOPICS} per prompt; '
                             'long outputs make reflections generic. Run it again for the next batch.')
    wants_pack = bool(args.topics or args.count or args.pack_only)
    if args.seed is None:
        args.seed = int(time.time()) % 1_000_000
        if wants_pack:
            say(f'seed: {args.seed}  (pass --seed {args.seed} to repeat this run)')
    if args.pack_only and not (args.topics or args.count):
        args.count = MAX_TOPICS

    if args.pack_only:
        print(build_pack(args))
        return

    template_path = resolve('reflection_prompt_template.md', 'prompt template', args.template)
    template = template_path.read_text(encoding='utf-8')
    parts = re.split(r'^=====$', template, flags=re.M)
    if len(parts) < 3:
        raise SystemExit('The template needs the prompt between two lines that contain only =====')
    prompt = parts[1].strip()

    if wants_pack:
        if START not in prompt or END not in prompt:
            raise SystemExit(f'The template is missing the {START} / {END} markers.')
        pack = build_pack(args)
        prompt = re.sub(re.escape(START) + r'.*?' + re.escape(END), lambda _: pack, prompt, flags=re.S)
    prompt = prompt.replace(START + '\n', '').replace('\n' + END, '').replace(START, '').replace(END, '')
    print(prompt)


if __name__ == '__main__':
    main()
