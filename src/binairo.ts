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
        let value = '';
        for (let i = 0; i < 10; i++) {
            value += '| ';
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

    public isValid(): boolean {
        for (let i = 0; i < 10; i++) {
            if (this.getNumberOfSameValue(this.getRow(i)) !== 5) {
                console.log(`Row ${i} has ${this.getNumberOfSameValue(this.getRow(i))} same values`);
                return false;
            }
            if (this.getNumberOfSameValue(this.getColumn(i)) !== 5) {
                console.log(`Column ${i} has ${this.getNumberOfSameValue(this.getColumn(i))} same values`);
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
}
