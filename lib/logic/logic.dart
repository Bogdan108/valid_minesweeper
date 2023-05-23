import 'dart:math';
import 'package:flutter/material.dart';
import 'package:valid_minesweeper/activities/ceil.dart';
import 'package:valid_minesweeper/settings/start_settings.dart';
import 'package:valid_minesweeper/utils/image_enum.dart';
import 'package:valid_minesweeper/utils/image_manage.dart';

class Logic {
  int _rowCount = MySettings.getrowCount();
  int _columnCount = MySettings.getcolumnCount();
  int _bombsCount = MySettings.getbombCount();

  late int _firstX;
  late int _firstY;
  late dynamic _random;
  late bool _stopBot;

  // Массив содержащий объекты клеток
  late List<List<Ceil>> _playground;
  late List<List<Ceil>> _testGround;

  // Инициализация игры
  void initialiseLogic() {
    _random = Random();
    _stopBot = false;
    _firstX = -1;
    _firstY = -1;

    _rowCount = MySettings.getrowCount();
    _columnCount = MySettings.getcolumnCount();
    _bombsCount = MySettings.getbombCount();

    _playground = List.generate(_rowCount, (i) {
      return List.generate(_columnCount, (j) {
        return Ceil();
      });
    });

    _testGround = List.generate(_rowCount, (i) {
      return List.generate(_columnCount, (j) {
        return Ceil();
      });
    });
  }

  bool boardGenerator(int rowNumber, int columnNumber) {
    bool isValid = false;
    int localCounter = 0;
    _firstX = rowNumber;
    _firstY = columnNumber;
    while (!isValid) {
      localCounter++;
      if (localCounter >= 1100) {
        return false;
      }

      _playground = List.generate(_rowCount, (i) {
        return List.generate(_columnCount, (j) {
          return Ceil();
        });
      });

      _testGround = List.generate(_rowCount, (i) {
        return List.generate(_columnCount, (j) {
          return Ceil();
        });
      });

      for (var i = 0; i < _rowCount; i++) {
        for (var j = 0; j < _columnCount; j++) {
          _playground[i][j].bombsAround = 0;
          _playground[i][j].isBomb = false;
          _testGround[i][j].bombsAround = 0;
          _testGround[i][j].isBomb = false;
        }
      }
      // обработка первого хода
      for (var i = _firstX - 1; i <= _firstX + 1; i++) {
        for (var j = _firstY - 1; j <= _firstY + 1; j++) {
          if (i >= 0 && i < _rowCount && j >= 0 && j < _columnCount) {
            _playground[i][j].isBooked = true;
            _testGround[i][j].isBooked = true;
          }
        }
      }

      // Случайная расстановка бомб с учётом первого хода
      for (var i = 0; i < _bombsCount; i++) {
        int x, y;
        do {
          x = _random.nextInt(_rowCount);
          y = _random.nextInt(_columnCount);
        } while (_playground[x][y].isBomb || _playground[x][y].isBooked);
        _playground[x][y].isBomb = true;
        _testGround[x][y].isBomb = true;
      }

      // Функция вычисления бомб рядом с клеткой

      for (var i = 0; i < _rowCount; i++) {
        for (var j = 0; j < _columnCount; j++) {
          _playground[i][j].bombsAround = _countBombsAround(i, j, _playground);
          _testGround[i][j].bombsAround = _countBombsAround(i, j, _testGround);
        }
      }
      isValid = _botValidator(isValid);
    }
    return true;
  }

  bool _botValidator(bool validFlag) {
    _botTap(_firstX, _firstY);

    while (!_isWin(_testGround) && !_stopBot) {
      bool specialMove = false;
      for (var i = 0; i < _rowCount; i++) {
        for (var j = 0; j < _columnCount; j++) {
          if (_testGround[i][j].bombsAround > 0 && !_testGround[i][j].isBomb) {
            // теперь обрабатываю каждую клетку
            var closedCount = 0;
            var flagedCount = 0;
            for (var dx = i - 1; dx <= i + 1; dx++) {
              for (var dy = j - 1; dy <= j + 1; dy++) {
                if (dx >= 0 && dx < _rowCount && dy >= 0 && dy < _columnCount) {
                  if (!_testGround[dx][dy].isOpen) {
                    closedCount++;
                  }
                  if (_testGround[dx][dy].isFlaged &&
                      !_testGround[dx][dy].isOpen) {
                    flagedCount++;
                  }
                }
              }
            }
            // проверка, что кол-во неоткрытых клеток вокруг равно количесву бомб вокруг
            if (closedCount == _testGround[i][j].bombsAround) {
              for (var dx = i - 1; dx <= i + 1; dx++) {
                for (var dy = j - 1; dy <= j + 1; dy++) {
                  if (dx >= 0 &&
                      dx < _rowCount &&
                      dy >= 0 &&
                      dy < _columnCount) {
                    if (!_testGround[dx][dy].isFlaged) {
                      _testGround[dx][dy].isFlaged = true;
                      specialMove = true;
                    }
                  }
                }
              }
            }

            if (flagedCount == _testGround[i][j].bombsAround) {
              for (var dx = i - 1; dx <= i + 1; dx++) {
                for (var dy = j - 1; dy <= j + 1; dy++) {
                  if (dx >= 0 &&
                      dx < _rowCount &&
                      dy >= 0 &&
                      dy < _columnCount) {
                    if (!_testGround[dx][dy].isFlaged) {
                      _testGround[dx][dy].isOpen = true;
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
    validFlag = _isWin(_testGround);
    return validFlag;
  }

  void _botTap(int i, int j) {
    _testGround[i][j].isOpen = true;
    if (_testGround[i][j].bombsAround == 0) {
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final nx = i + dx;
          final ny = j + dy;
          if (nx >= 0 &&
              nx < _rowCount &&
              ny >= 0 &&
              ny < _columnCount &&
              !_testGround[nx][ny].isOpen) {
            _botTap(nx, ny);
          }
        }
      }
    }
  }

  bool _isWin(List<List<Ceil>> testGround) {
    for (var i = 0; i < _rowCount; i++) {
      for (var j = 0; j < _columnCount; j++) {
        if (!testGround[i][j].isOpen && !testGround[i][j].isBomb) {
          return false;
        }
      }
    }
    return true;
  }

  bool isWinPr() {
    for (var i = 0; i < _rowCount; i++) {
      for (var j = 0; j < _columnCount; j++) {
        if (!_playground[i][j].isOpen && !_playground[i][j].isBomb) {
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
        if (i >= 0 && i < _rowCount && j >= 0 && j < _columnCount) {
          if (ground[i][j].isBomb) bombsCount++;
        }
      }
    }
    return bombsCount;
  }

  void handleTap(int i, int j) {
    //_ceilsFree = _ceilsFree - 1;
    print("pltcm \n");
    _playground[i][j].isOpen = true;
    if (_playground[i][j].bombsAround == 0) {
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final nx = i + dx;
          final ny = j + dy;
          if (nx >= 0 &&
              nx < _rowCount &&
              ny >= 0 &&
              ny < _columnCount &&
              !_playground[nx][ny].isOpen) {
            handleTap(nx, ny);
          }
        }
      }
    }
  }

  Ceil getPlayground(int row, int column) {
    return _playground[row][column];
  }

  int getBombCount() {
    return _bombsCount;
  }

  void setBombCount(bool flag) {
    if (flag) {
      _bombsCount++;
    } else {
      _bombsCount--;
    }
  }

  Image getImage(int position) {
    int rowNumber = (position / _columnCount).floor();
    int columnNumber = (position % _columnCount);

    Image image;

    if (_playground[rowNumber][columnNumber].isOpen == false) {
      if (_playground[rowNumber][columnNumber].isFlaged == true) {
        image = ImageManager.getImage(ImageType.flagged);
        _playground[rowNumber][columnNumber].isHint = false;
      } else {
        image = ImageManager.getImage(ImageType.facingDown);
      }
      if (_playground[rowNumber][columnNumber].isHint) {
        image = Image.asset("images/facingDown.png",
            color: const Color.fromARGB(255, 217, 219, 82));
      }
    } else {
      if (_playground[rowNumber][columnNumber].isBomb) {
        image = ImageManager.getImage(ImageType.bomb);
      } else {
        image = ImageManager.getImage(
          ImageManager.getImageTypeFromNumber(
              _playground[rowNumber][columnNumber].bombsAround),
        );
      }
    }
    return image;
  }
}
