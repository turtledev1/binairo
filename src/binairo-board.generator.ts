import { Binairo } from './binairo';

export class BinairoBoardGenerator {
    constructor() { }

    public generate() {
        const binairo = new Binairo();

        this.generateRow(binairo, 0);
        this.generateRow(binairo, 1);

        for (let rowIndex = 2; rowIndex < 10; rowIndex++) {
            this.generateRowWithColumnAwareness(binairo, rowIndex);
        }

        return binairo;
    }

    private generateRow(binairo: Binairo, rowIndex: number) {
        this.checkLastResort(binairo, rowIndex, 0);
        this.checkLastResort(binairo, rowIndex, 1);

        for (let columnIndex = 2; columnIndex < 10; columnIndex++) {
            this.checkRowForPrioritization(binairo, rowIndex, columnIndex);
            this.checkPreviousTwoValues(binairo, rowIndex, columnIndex);
            this.checkRowForMax(binairo, rowIndex, columnIndex);
            this.checkLastResort(binairo, rowIndex, columnIndex);
        }
    }

    private generateRowWithColumnAwareness(binairo: Binairo, rowIndex: number) {
        this.checkColumnForPrioritization(binairo, rowIndex, 0);
        this.checkTopTwoValues(binairo, rowIndex, 0);
        this.checkColumnForMax(binairo, rowIndex, 0);
        this.checkLastResort(binairo, rowIndex, 0);

        this.checkColumnForPrioritization(binairo, rowIndex, 1);
        this.checkTopTwoValues(binairo, rowIndex, 1);
        this.checkColumnForMax(binairo, rowIndex, 1);
        this.checkLastResort(binairo, rowIndex, 1);

        for (let columnIndex = 2; columnIndex < 10; columnIndex++) {
            this.checkRowForPrioritization(binairo, rowIndex, columnIndex);
            this.checkColumnForPrioritization(binairo, rowIndex, columnIndex);
            this.checkTopTwoValues(binairo, rowIndex, columnIndex);
            this.checkColumnForMax(binairo, rowIndex, columnIndex);
            this.checkPreviousTwoValues(binairo, rowIndex, columnIndex);
            this.checkRowForMax(binairo, rowIndex, columnIndex);
            this.checkLastResort(binairo, rowIndex, columnIndex);
        }
    }

    private checkPreviousTwoValues(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.areTwoNumbersBeforeSame(binairo, rowIndex, columnIndex)) {
            binairo.setValue(rowIndex, columnIndex, !binairo.getValue(rowIndex, columnIndex - 1));
        }
    }

    private checkRowForMax(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.isMaxReachedForRow(binairo, rowIndex, columnIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
        if (this.isMaxReachedForRow(binairo, rowIndex, columnIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
    }

    private checkColumnForMax(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.isMaxReachedForColumn(binairo, rowIndex, columnIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
        if (this.isMaxReachedForColumn(binairo, rowIndex, columnIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
    }

    private checkTopTwoValues(binairo: Binairo, rowIndex: number, columnIndex: number) {
        if (this.areTwoNumbersAboveSame(binairo, rowIndex, columnIndex)) {
            binairo.setValue(rowIndex, columnIndex, !binairo.getValue(rowIndex - 1, columnIndex));
        }
    }

    private checkRowForPrioritization(binairo: Binairo, rowIndex: number, columnIndex: number) {
        const isColumn4Or5 = columnIndex === 4 || columnIndex === 5;
        if (isColumn4Or5 && this.getSumForValue(binairo.getRow(rowIndex), columnIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
        if (isColumn4Or5 && this.getSumForValue(binairo.getRow(rowIndex), columnIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
    }

    private checkColumnForPrioritization(binairo: Binairo, rowIndex: number, columnIndex: number) {
        const isRow4Or5 = rowIndex === 4 || rowIndex === 5;
        if (isRow4Or5 && this.getSumForValue(binairo.getColumn(columnIndex), rowIndex, false)) {
            binairo.setValue(rowIndex, columnIndex, true);
        }
        if (isRow4Or5 && this.getSumForValue(binairo.getColumn(columnIndex), rowIndex, true)) {
            binairo.setValue(rowIndex, columnIndex, false);
        }
    }

    private checkLastResort(binairo: Binairo, rowIndex: number, columnIndex: number) {
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
