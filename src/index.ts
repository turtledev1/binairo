import { generate } from "./generator"

const board = generate();
console.log('Binairo board');
// console.log(board.toString());
console.log(board.isValid() ? 'Valid' : 'Invalid');
