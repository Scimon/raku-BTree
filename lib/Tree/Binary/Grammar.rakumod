unit package Tree::Binary;

grammar Grammar {
    token TOP { <tree> };
    token tree { <value> ["(" $<left>=<tree> ")"]? ["(" $<right>=<tree> ")"]? };
    regex value { <-[()]>+ }
}
