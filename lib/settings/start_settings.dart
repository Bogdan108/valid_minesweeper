class MySettings {
  // базовые настройки
  static int _rowCount = 8;
  static int _columnCount = 8;
  static int _bombCount = 10;
  static int _style = 0;
  static bool _custom = false;

  static void setSize(int row, int column) {
    _rowCount = row;
    _columnCount = column;
  }

  static void setBombs(int bombs) {
    _bombCount = bombs;
  }

  static void setStyle(int style) {
    _style = style;
  }

  static void setCustom(bool custom) {
    _custom = custom;
  }

  static int getrowCount() {
    return _rowCount;
  }

  static int getcolumnCount() {
    return _columnCount;
  }

  static int getbombCount() {
    return _bombCount;
  }

  static int getStyle() {
    return _style;
  }

  static bool getCustom() {
    return _custom;
  }
}
