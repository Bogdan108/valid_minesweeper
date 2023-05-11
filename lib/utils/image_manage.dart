import 'package:valid_minesweeper/settings/start_settings.dart';
import 'package:flutter/material.dart';
import 'package:valid_minesweeper/utils/image_enum.dart';

class ImageManager {
  static Image getImage(ImageType type) {
    if (MySettings.getStyle() == 0) {
      switch (type) {
        case ImageType.zero:
          return Image.asset('images/0.png');
        case ImageType.one:
          return Image.asset('images/1.png');
        case ImageType.two:
          return Image.asset('images/2.png');
        case ImageType.three:
          return Image.asset('images/3.png');
        case ImageType.four:
          return Image.asset('images/4.png');
        case ImageType.five:
          return Image.asset('images/5.png');
        case ImageType.six:
          return Image.asset('images/6.png');
        case ImageType.seven:
          return Image.asset('images/7.png');
        case ImageType.eight:
          return Image.asset('images/8.png');
        case ImageType.bomb:
          return Image.asset('images/bomb.png');
        case ImageType.facingDown:
          return Image.asset('images/facingDown.png');
        case ImageType.flagged:
          return Image.asset('images/flagged.png');
        default:
          return Image.asset('images/flagged.png');
      }
    } else {
      switch (type) {
        case ImageType.zero:
          return Image.asset('images/0.png');
        case ImageType.one:
          return Image.asset('images/12.png');
        case ImageType.two:
          return Image.asset('images/22.png');
        case ImageType.three:
          return Image.asset('images/32.png');
        case ImageType.four:
          return Image.asset('images/42.png');
        case ImageType.five:
          return Image.asset('images/52.png');
        case ImageType.six:
          return Image.asset('images/62.png');
        case ImageType.seven:
          return Image.asset('images/72.png');
        case ImageType.eight:
          return Image.asset('images/82.png');
        case ImageType.bomb:
          return Image.asset('images/bomb.png');
        case ImageType.facingDown:
          return Image.asset('images/facingDown.png');
        case ImageType.flagged:
          return Image.asset('images/flagged.png');
        default:
          return Image.asset('images/flagged.png');
      }
    }
  }

  static ImageType getImageTypeFromNumber(int number) {
    switch (number) {
      case 0:
        return ImageType.zero;
      case 1:
        return ImageType.one;
      case 2:
        return ImageType.two;
      case 3:
        return ImageType.three;
      case 4:
        return ImageType.four;
      case 5:
        return ImageType.five;
      case 6:
        return ImageType.six;
      case 7:
        return ImageType.seven;
      case 8:
        return ImageType.eight;
      default:
        return ImageType.eight;
    }
  }
}
