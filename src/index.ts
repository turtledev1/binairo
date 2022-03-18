import { generate, generateWithIteration } from "./generator"

const board = generateWithIteration();
console.log('Binairo board');
console.log(board.toString());
console.log(board.isValid() ? 'Valid' : 'Invalid');
