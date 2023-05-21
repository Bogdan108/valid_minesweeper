import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:valid_minesweeper/activities/ceil.dart';
import 'package:valid_minesweeper/settings/start_settings.dart';
import 'package:valid_minesweeper/utils/image_enum.dart';
import 'package:valid_minesweeper/utils/image_manage.dart';
import 'package:valid_minesweeper/activities/game.dart';

class Logic {
  int rowCount = MySettings.getrowCount();
  int columnCount = MySettings.getcolumnCount();
  int bombsCount = MySettings.getbombCount();
  late int ceilsFreeTest;
  late bool firstStep;
  late int firstX;
  late int firstY;
  late int hintCount;
  late dynamic random;
  late Timer? timer;
  int seconds = 0;
  late bool stopBot;

  // Массив содержащий объекты клеток
  late List<List<Ceil>> playground;
  late List<List<Ceil>> testGround;
  late int ceilsFree;

  // Инициализация игры
  void initialiseLogic() {
    hintCount = 3;
    random = Random();
    firstStep = false;
    stopBot = false;
    firstX = -1;
    firstY = -1;

    rowCount = MySettings.getrowCount();
    columnCount = MySettings.getcolumnCount();
    bombsCount = MySettings.getbombCount();

    // установка количества свободных клеток
    ceilsFree = rowCount * columnCount;

    //  время
    seconds = 0;
    playground = List.generate(rowCount, (i) {
      return List.generate(columnCount, (j) {
        return Ceil();
      });
    });

    testGround = List.generate(rowCount, (i) {
      return List.generate(columnCount, (j) {
        return Ceil();
      });
    });
  }

  bool boardGenerator(int rowNumber, int columnNumber) {
    bool isValid = false;
    int localCounter = 0;
    firstX = rowNumber;
    firstY = columnNumber;
    while (!isValid) {
      localCounter++;
      if (localCounter >= 1100) {
        return false;
      }

      ceilsFreeTest = rowCount * columnCount;
      playground = List.generate(rowCount, (i) {
        return List.generate(columnCount, (j) {
          return Ceil();
        });
      });

      testGround = List.generate(rowCount, (i) {
        return List.generate(columnCount, (j) {
          return Ceil();
        });
      });

      for (var i = 0; i < rowCount; i++) {
        for (var j = 0; j < columnCount; j++) {
          playground[i][j].bombsAround = 0;
          playground[i][j].isBomb = false;
          testGround[i][j].bombsAround = 0;
          testGround[i][j].isBomb = false;
        }
      }
      // обработка первого хода
      for (var i = firstX - 1; i <= firstX + 1; i++) {
        for (var j = firstY - 1; j <= firstY + 1; j++) {
          if (i >= 0 && i < rowCount && j >= 0 && j < columnCount) {
            playground[i][j].isBooked = true;
            testGround[i][j].isBooked = true;
          }
        }
      }

      // Случайная расстановка бомб с учётом первого хода
      for (var i = 0; i < bombsCount; i++) {
        int x, y;
        do {
          x = random.nextInt(rowCount);
          y = random.nextInt(columnCount);
        } while (playground[x][y].isBomb || playground[x][y].isBooked);
        --ceilsFree;
        --ceilsFreeTest;
        playground[x][y].isBomb = true;
        testGround[x][y].isBomb = true;
      }

      // Функция вычисления бомб рядом с клеткой

      for (var i = 0; i < rowCount; i++) {
        for (var j = 0; j < columnCount; j++) {
          playground[i][j].bombsAround = _countBombsAround(i, j, playground);
          testGround[i][j].bombsAround = _countBombsAround(i, j, testGround);
        }
      }
      isValid = botValidator(isValid);
    }
    return true;
  }

  bool botValidator(bool validFlag) {
    _botTap(firstX, firstY);

    while (!isWin(testGround) && !stopBot) {
      bool specialMove = false;
      for (var i = 0; i < rowCount; i++) {
        for (var j = 0; j < columnCount; j++) {
          if (testGround[i][j].bombsAround > 0 && !testGround[i][j].isBomb) {
            // теперь обрабатываю каждую клетку
            var closedCount = 0;
            var flagedCount = 0;
            for (var dx = i - 1; dx <= i + 1; dx++) {
              for (var dy = j - 1; dy <= j + 1; dy++) {
                if (dx >= 0 && dx < rowCount && dy >= 0 && dy < columnCount) {
                  if (!testGround[dx][dy].isOpen) {
                    closedCount++;
                  }
                  if (testGround[dx][dy].isFlaged &&
                      !testGround[dx][dy].isOpen) {
                    flagedCount++;
                  }
                }
              }
            }
            // проверка, что кол-во неоткрытых клеток вокруг равно количесву бомб вокруг
            if (closedCount == testGround[i][j].bombsAround) {
              for (var dx = i - 1; dx <= i + 1; dx++) {
                for (var dy = j - 1; dy <= j + 1; dy++) {
                  if (dx >= 0 && dx < rowCount && dy >= 0 && dy < columnCount) {
                    if (!testGround[dx][dy].isFlaged) {
                      testGround[dx][dy].isFlaged = true;
                      specialMove = true;
                    }
                  }
                }
              }
            }

            if (flagedCount == testGround[i][j].bombsAround) {
              for (var dx = i - 1; dx <= i + 1; dx++) {
                for (var dy = j - 1; dy <= j + 1; dy++) {
                  if (dx >= 0 && dx < rowCount && dy >= 0 && dy < columnCount) {
                    if (!testGround[dx][dy].isFlaged) {
                      testGround[dx][dy].isOpen = true;
                      _botTap(dx, dy);
                      specialMove = true;
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (specialMove == false) {
        break;
      }
    }
    validFlag = isWin(testGround);
    return validFlag;
  }

  void _botTap(int i, int j) {
    ceilsFreeTest = ceilsFreeTest - 1;
    testGround[i][j].isOpen = true;
    if (testGround[i][j].bombsAround == 0) {
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final nx = i + dx;
          final ny = j + dy;
          if (nx >= 0 &&
              nx < rowCount &&
              ny >= 0 &&
              ny < columnCount &&
              !testGround[nx][ny].isOpen) {
            _botTap(nx, ny);
          }
        }
      }
    }
  }

  bool isWin(List<List<Ceil>> testGround) {
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < columnCount; j++) {
        if (!testGround[i][j].isOpen && !testGround[i][j].isBomb) {
          return false;
        }
      }
    }
    return true;
  }

  int _countBombsAround(int x, int y, List<List<Ceil>> ground) {
    var bombsCount = 0;
    for (var i = x - 1; i <= x + 1; i++) {
      for (var j = y - 1; j <= y + 1; j++) {
        if (i >= 0 && i < rowCount && j >= 0 && j < columnCount) {
          if (ground[i][j].isBomb) bombsCount++;
        }
      }
    }
    return bombsCount;
  }

  void handleTap(int i, int j) {
    ceilsFree = ceilsFree - 1;
    playground[i][j].isOpen = true;
    if (playground[i][j].bombsAround == 0) {
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final nx = i + dx;
          final ny = j + dy;
          if (nx >= 0 &&
              nx < rowCount &&
              ny >= 0 &&
              ny < columnCount &&
              !playground[nx][ny].isOpen) {
            handleTap(nx, ny);
          }
        }
      }
    }
  }

  Image getImage(int position) {
    int rowNumber = (position / columnCount).floor();
    int columnNumber = (position % columnCount);

    Image image;

    if (playground[rowNumber][columnNumber].isOpen == false) {
      if (playground[rowNumber][columnNumber].isFlaged == true) {
        image = ImageManager.getImage(ImageType.flagged);
        playground[rowNumber][columnNumber].isHint = false;
      } else {
        image = ImageManager.getImage(ImageType.facingDown);
      }
      if (playground[rowNumber][columnNumber].isHint) {
        image = Image.asset("images/facingDown.png",
            color: const Color.fromARGB(255, 217, 219, 82));
      }
    } else {
      if (playground[rowNumber][columnNumber].isBomb) {
        image = ImageManager.getImage(ImageType.bomb);
      } else {
        image = ImageManager.getImage(
          ImageManager.getImageTypeFromNumber(
              playground[rowNumber][columnNumber].bombsAround),
        );
      }
    }
    return image;
  }
}
