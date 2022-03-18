import { Binairo } from "./binairo";

enum Prority {
    Important,
    NotImportant,
}

export class BinairoRowVisitor {
    constructor() { }

    public visit(binairo: Binairo, rowIndex: number) {
        // randomize the row
        for (let columnIndex = 0; columnIndex < 10; columnIndex++) {
            binairo.setValue(rowIndex, columnIndex, this.randomBoolean());
        }

        for (let columnIndex = 2; columnIndex < 10; columnIndex++) {
            this.visitPreviousTwoValues(binairo, rowIndex, columnIndex);
            this.visitRowForMax(binairo, rowIndex, columnIndex);
        }
    }

    public visitWithColumnAwareness(binairo: Binairo, rowIndex: number) {
        // randomize the row
        for (let columnIndex = 0; columnIndex < 10; columnIndex++) {
            binairo.setValue(rowIndex, columnIndex, this.randomBoolean());
        }

        this.visitTopTwoValues(binairo, rowIndex, 0);
        this.visitColumnForMax(binairo, rowIndex, 0);

        this.visitTopTwoValues(binairo, rowIndex, 1);
        this.visitColumnForMax(binairo, rowIndex, 1);

        for (let columnIndex = 2; columnIndex < 10; columnIndex++) {
            this.visitTopTwoValues(binairo, rowIndex, columnIndex);
            this.visitColumnForMax(binairo, rowIndex, columnIndex);
            this.visitPreviousTwoValues(binairo, rowIndex, columnIndex);
            this.visitRowForMax(binairo, rowIndex, columnIndex);
        }
    }

    private visitPreviousTwoValues(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.areTwoNumbersBeforeSame(binairo, rowIndex, columnIndex)) {
            binairo.setValue(rowIndex, columnIndex, !binairo.getValue(rowIndex, columnIndex - 1));
        }
    }

    private visitRowForMax(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.isMaxReachedForRow(binairo, rowIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
        if (this.isMaxReachedForRow(binairo, rowIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
    }

    private visitColumnForMax(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.isMaxReachedForColumn(binairo, columnIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
        if (this.isMaxReachedForColumn(binairo, columnIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
    }

    private visitTopTwoValues(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.areTwoNumbersAboveSame(binairo, rowIndex, columnIndex)) {
            binairo.setValue(rowIndex, columnIndex, !binairo.getValue(rowIndex - 1, columnIndex));
        }
    }

    private areTwoNumbersAboveSame(binairo: Binairo, rowIndex: number, columnIndex: number) {
        return binairo.getValue(rowIndex - 1, columnIndex) === binairo.getValue(rowIndex - 2, columnIndex);
    }

    private areTwoNumbersBeforeSame(binairo: Binairo, rowIndex: number, columnIndex: number) {
        return binairo.getValue(rowIndex, columnIndex - 1) === binairo.getValue(rowIndex, columnIndex - 2);
    }

    private isMaxReachedForRow(binairo: Binairo, rowIndex: number, valueToCheck: boolean) {
        return this.getSumForValue(binairo.getRow(rowIndex), valueToCheck) === 5;
    }

    private isMaxReachedForColumn(binairo: Binairo, columnIndex: number, valueToCheck: boolean) {
        return this.getSumForValue(binairo.getColumn(columnIndex), valueToCheck) === 5;
    }

    private getSumForValue(rowOrColumn: Array<boolean>, valueToCheck: boolean): number {
        let numberOfSameValue = 0;
        rowOrColumn.forEach(value => {
            if (value === valueToCheck) {
                numberOfSameValue++;
            }
        });

        return numberOfSameValue;
    }

    private randomBoolean() {
        return Math.random() > 0.5;
    }
}
