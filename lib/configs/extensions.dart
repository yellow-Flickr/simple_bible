import 'package:simple_bible/configs/assets.dart';

extension DayStatus on DateTime {
  (String,String) greeting() {
    if (hour < 12) {
      return ('Good Morning!',LottieAssets.sunrise);
    } else if (hour < 15) {
            return ('Good Day!',LottieAssets.midday);

    }else if (hour < 19) {
            return ('Good Evening!',LottieAssets.sunset);

    } else {
            return ('Good Night!',LottieAssets.night);

    }
  }
}
