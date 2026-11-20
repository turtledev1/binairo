enum CellValue {
  empty,
  zero,
  one;

  bool get isEmpty => this == CellValue.empty;

  bool get isFilled => this != CellValue.empty;

  CellValue get opposite => switch (this) {
    CellValue.zero => CellValue.one,
    CellValue.one => CellValue.zero,
    CellValue.empty => CellValue.empty,
  };

  CellValue get nextInTapCycle => switch (this) {
    CellValue.empty => CellValue.zero,
    CellValue.zero => CellValue.one,
    CellValue.one => CellValue.empty,
  };
}
