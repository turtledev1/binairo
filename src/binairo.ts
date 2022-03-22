export class Binairo {
    private board: Array<Array<boolean>>;

    constructor() {
        this.board = new Array<Array<boolean>>(10);
        for (let i = 0; i < 10; i++) {
            const row = new Array<boolean>(10);
            this.board[i] = row;
        }
    }

    public toString(): string {
        let value = '    0   1   2   3   4   5   6   7   8   9\n';
        for (let i = 0; i < 10; i++) {
            value += i + ' | ';
            this.getRow(i).forEach((num, index) => {
                value += num ? '1' : '0';
                if (index < 9) {
                    value += ' | ';
                }
            });
            value += ' |\n';
        }
        return value;
    }

    public getValue(row: number, column: number): boolean {
        return this.getRow(row)[column];
    }

    public setValue(row: number, column: number, value: boolean) {
        this.getRow(row)[column] = value;
    }

    public getRow(index: number): Array<boolean> {
        return this.board[index];
    }

    public getColumn(index: number): Array<boolean> {
        const column = new Array<boolean>(10);

        for (let i = 0; i < 10; i++) {
            column[i] = this.getRow(i)[index];
        }

        return column;
    }

    public isValid(log: boolean = false): boolean {
        for (let i = 0; i < 10; i++) {
            const row = this.getRow(i);
            const column = this.getColumn(i);
            if (this.getNumberOfSameValue(row) !== 5) {
                if (log) {
                    console.log(`Row ${i} has ${this.getNumberOfSameValue(this.getRow(i))} same values`);
                }
                return false;
            }
            if (this.getNumberOfSameValue(column) !== 5) {
                if (log) {
                    console.log(`Column ${i} has ${this.getNumberOfSameValue(this.getColumn(i))} same values`);
                }
                return false;
            }
            if (this.isNumberPresentThreeTimesInARow(row)) {
                if (log) {
                    console.log(`Row ${i} has three of same value in a row`);
                }
                return false;
            }
            if (this.isNumberPresentThreeTimesInARow(column)) {
                if (log) {
                    console.log(`Column ${i} has three of same value in a row`);
                }
                return false;
            }
        }
        return true;
    }

    private getNumberOfSameValue(rowOrColumn: Array<boolean>): number {
        let numberOfSameValue = 0;
        rowOrColumn.forEach(value => {
            if (value) {
                numberOfSameValue++;
            }
        });

        return numberOfSameValue;
    }

    private isNumberPresentThreeTimesInARow(rowOrColumn: Array<boolean>): boolean {
        let counter0 = 0;
        let counter1 = 0;
        for (let i = 0; i < 10; i++) {
            if (rowOrColumn[i]) {
                counter1++;
                counter0 = 0;
                if (counter1 > 2) {
                    return true;
                }
            } else {
                counter0++;
                counter1 = 0;
                if (counter0 > 2) {
                    return true;
                }
            }
        }
        return false;
    }
}
