unit package Tree::Binary::Role;

role Tree::Binary {...}

role Renderer is export {
    method new(Tree::Binary :$tree) {...}
    method render() {...}
}
   
