unit package Tree::Binary::Role;

role BinaryTree {...}

role Renderer is export {
    method new(Tree::Binary::Role::BinaryTree :$tree) {...}
    method render() {...}
}
   
