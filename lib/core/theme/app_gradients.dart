import 'package:flutter/widgets.dart';
import 'app_colors.dart';

class AppGradients {
  const AppGradients._();

  static const LinearGradient cta = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[AppColors.coral, AppColors.magenta],
  );

  static const LinearGradient marketingBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.pinkBgStart, AppColors.plumBgEnd],
  );

  static const RadialGradient marketingBlob = RadialGradient(
    colors: <Color>[Color(0x33F06AAE), Color(0x00F06AAE)],
  );
}
