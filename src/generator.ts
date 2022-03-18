import { Binairo } from "./binairo";
import { BinairoRowVisitor } from "./binairo-row-visitor";

export function generate(): Binairo {
    const binairo = new Binairo();
    const binairoVisitor = new BinairoRowVisitor();

    binairoVisitor.visit(binairo, 0);
    binairoVisitor.visit(binairo, 1);

    for (let rowIndex = 2; rowIndex < 10; rowIndex++) {
        binairoVisitor.visitWithColumnAwareness(binairo, rowIndex);
    }
    console.log(binairo.toString());
    return binairo;
}
