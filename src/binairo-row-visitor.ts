import { Binairo } from "./binairo";

export class BinairoRowVisitor {
    constructor() { }

    public visit(binairo: Binairo, rowIndex: number) {
        this.visitLastResort(binairo, rowIndex, 0);
        this.visitLastResort(binairo, rowIndex, 1);

        for (let columnIndex = 2; columnIndex < 10; columnIndex++) {
            this.visitRowForPrioritization(binairo, rowIndex, columnIndex);
            this.visitPreviousTwoValues(binairo, rowIndex, columnIndex);
            this.visitRowForMax(binairo, rowIndex, columnIndex);
            this.visitLastResort(binairo, rowIndex, columnIndex);
        }
    }

    public visitWithColumnAwareness(binairo: Binairo, rowIndex: number) {
        this.visitColumnForPrioritization(binairo, rowIndex, 0);
        this.visitTopTwoValues(binairo, rowIndex, 0);
        this.visitColumnForMax(binairo, rowIndex, 0);
        this.visitLastResort(binairo, rowIndex, 0);

        this.visitColumnForPrioritization(binairo, rowIndex, 1);
        this.visitTopTwoValues(binairo, rowIndex, 1);
        this.visitColumnForMax(binairo, rowIndex, 1);
        this.visitLastResort(binairo, rowIndex, 1);

        for (let columnIndex = 2; columnIndex < 10; columnIndex++) {
            this.visitRowForPrioritization(binairo, rowIndex, columnIndex);
            this.visitColumnForPrioritization(binairo, rowIndex, columnIndex);
            this.visitTopTwoValues(binairo, rowIndex, columnIndex);
            this.visitColumnForMax(binairo, rowIndex, columnIndex);
            this.visitPreviousTwoValues(binairo, rowIndex, columnIndex);
            this.visitRowForMax(binairo, rowIndex, columnIndex);
            this.visitLastResort(binairo, rowIndex, columnIndex);
        }
    }

    private visitPreviousTwoValues(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.areTwoNumbersBeforeSame(binairo, rowIndex, columnIndex)) {
            binairo.setValue(rowIndex, columnIndex, !binairo.getValue(rowIndex, columnIndex - 1));
        }
    }

    private visitRowForMax(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.isMaxReachedForRow(binairo, rowIndex, columnIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
        if (this.isMaxReachedForRow(binairo, rowIndex, columnIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
    }

    private visitColumnForMax(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.isMaxReachedForColumn(binairo, rowIndex, columnIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
        if (this.isMaxReachedForColumn(binairo, rowIndex, columnIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
    }

    private visitTopTwoValues(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.areTwoNumbersAboveSame(binairo, rowIndex, columnIndex)) {
            binairo.setValue(rowIndex, columnIndex, !binairo.getValue(rowIndex - 1, columnIndex));
        }
    }

    private visitRowForPrioritization(binairo: Binairo, rowIndex: number, columnIndex: number) {
        const isColumn4Or5 = columnIndex === 4 || columnIndex === 5;
        if (isColumn4Or5 && this.getSumForValue(binairo.getRow(rowIndex), columnIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
        if (isColumn4Or5 && this.getSumForValue(binairo.getRow(rowIndex), columnIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
    }

    private visitColumnForPrioritization(binairo: Binairo, rowIndex: number, columnIndex: number) {
        const isRow4Or5 = rowIndex === 4 || rowIndex === 5;
        if (isRow4Or5 && this.getSumForValue(binairo.getColumn(columnIndex), rowIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
        if (isRow4Or5 && this.getSumForValue(binairo.getColumn(columnIndex), rowIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
    }

    private visitLastResort(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (binairo.getValue(rowIndex, columnIndex) === undefined) {
            binairo.setValue(rowIndex, columnIndex, this.randomBoolean());
        }
    }

    private areTwoNumbersAboveSame(binairo: Binairo, rowIndex: number, columnIndex: number) {
        return binairo.getValue(rowIndex - 1, columnIndex) === binairo.getValue(rowIndex - 2, columnIndex);
    }

    private areTwoNumbersBeforeSame(binairo: Binairo, rowIndex: number, columnIndex: number) {
        return binairo.getValue(rowIndex, columnIndex - 1) === binairo.getValue(rowIndex, columnIndex - 2);
    }

    private isMaxReachedForRow(binairo: Binairo, rowIndex: number, columnIndex: number, valueToCheck: boolean) {
        return this.getSumForValue(binairo.getRow(rowIndex), columnIndex, valueToCheck) === 5;
    }

    private isMaxReachedForColumn(binairo: Binairo, rowIndex: number, columnIndex: number, valueToCheck: boolean) {
        return this.getSumForValue(binairo.getColumn(columnIndex), rowIndex, valueToCheck) === 5;
    }

    private getSumForValue(rowOrColumn: Array<boolean>, maxIndex: number, valueToCheck: boolean): number {
        let numberOfSameValue = 0;
        for (let i = 0; i < maxIndex; i++) {
            if (rowOrColumn[i] === valueToCheck) {
                numberOfSameValue++;
            }
        }

        return numberOfSameValue;
    }

    private randomBoolean() {
        return Math.random() > 0.5;
    }
}
