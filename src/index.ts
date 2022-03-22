import { BinairoBoardGenerator } from './binairo-board.generator';

for (let i = 0; i < 1000; i++) {
    const board = new BinairoBoardGenerator().generate();
    if (board.isValid(false)) {
        console.log('Binairo board #' + i);
        console.log(board.toString());
        console.log(board.isValid() ? 'Valid' : 'Invalid');
        break;
    }
}
