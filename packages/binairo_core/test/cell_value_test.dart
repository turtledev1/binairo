import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  test('tap cycle goes from empty to zero to one and back to empty', () {
    expect(CellValue.empty.nextInTapCycle, CellValue.zero);
    expect(CellValue.zero.nextInTapCycle, CellValue.one);
    expect(CellValue.one.nextInTapCycle, CellValue.empty);
  });

  test('opposite swaps zero and one and keeps empty as empty', () {
    expect(CellValue.zero.opposite, CellValue.one);
    expect(CellValue.one.opposite, CellValue.zero);
    expect(CellValue.empty.opposite, CellValue.empty);
  });
}
