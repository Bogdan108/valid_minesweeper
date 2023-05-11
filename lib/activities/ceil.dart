class Ceil {
  bool isBomb;
  int bombsAround;
  bool isOpen;
  bool isFlaged;
  bool isBooked;
  bool isHint;

  Ceil(
      // информация о клетке
      {this.isBomb = false,
      this.bombsAround = 0,
      this.isOpen = false,
      this.isFlaged = false,
      this.isBooked = false,
      this.isHint = false});
}
