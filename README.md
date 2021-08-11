[![Actions Status](https://github.com/Scimon/raku-BTree/workflows/test/badge.svg)](https://github.com/Scimon/raku-BTree/actions)

NAME
====

Tree::Binary - Simple Binary Tree Role with pretty printing

SYNOPSIS
========

```raku
use Tree::Binary;
class IntTree does Tree::Binary[Int] {};
my IntTree(Str) $tree = "1(2)(3)";
say $tree;
```

     1 
    ┌┴┐
    2 3

DESCRIPTION
===========

Tree::Binary is intended to be a simple role that can be used to represent binary trees. It's intended to be a basis for a series of different types for trees. 

Tree::Binary does not include code for inserting or deleting nodes as this is dependent on the concreate class using it. 

Tree::Binary
------------

```raku
role Tree::Binary[
    ::ValueType=Any,
    Tree::Binary::Role::Renderer :$gist-renderer=Tree::Binary::PrettyTree,
    Tree::Binary::Role::Renderer :$Str-renderer=Tree::Binary::PrettyTree,
]
```

The Tree::Binary `Role` accepts one postional and two named parameters : 

**ValueType**

The type of object it should allow (defaulting to Any)

**:$gist-renderer**

An output renderer used for creating the Tree::Binary's gist representation. The default for this is Tree::Binary::PrettyTree but any class that does Tree::Binary::Role::Renderer will work.

**:$Str-renderer**

An output renderer used for creating the Tree::Binary's Str representation. The default for this is BasicStrRenderer but any class that does Tree::Binary::Role::Renderer will work.

### Construction

The default constructor takes two named arguments :

**ValueType :$value**

The value of the current node

**Array[Tree::Binary] :@nodes[2]**

An array of 0-2 Tree::Binary nodes that are the children of the current node.

The role also allows for basic string coercion where a tree can be represented with the following structure.

    value(node1)(node2)

Where `value` is a `Str` that can be coerced into a `ValueType` and `node1` and `node2` another `Tree::Binary` representation. The `Str` method should produce a value that can be coered into a Tree::Binary of the appropriate `ValueType`.

Alternate construction options using `Str` coercion are :

```raku
# Coercion from a Str to a Tree::Binary
my Tree::Binary(Str) $tree1 = "1(a)(£)";

# Using the from-Str constructor
my $tree2 = Tree::Binary.from-Str("1(a)(£)");
```

### Attributes

### has ValueType $.value

The current nodes value

### has Positional[Tree::Binary::Role::Tree::Binary] @!nodes

The child nodes

### Methods

### method nodes

```raku
method nodes() returns Array[Tree::Binary::Role::Tree::Binary]
```

The child nodes of this node, undefined nodes will not be returned.

### method elems

```raku
method elems() returns UInt
```

Returns the number of defined nodes for the current node. Note that the elems method does NOT return the count of all nodes in the tree just the current nodes children.

### method elems

```raku
method elems(
    Bool :$all!
) returns UInt
```

With the :all flag returns the total number of nodes in the tree including the current one but not any undefined ones.

### method elems

```raku
method elems(
    Bool :$leaf!
) returns UInt
```

With the :leaf flag returns the total number of leaf nodes

### method Str

```raku
method Str() returns Str
```

Returns a Str representation of the tree using the :$Str-renderer parameter

### method gist

```raku
method gist() returns Str
```

Returns the gist for this tree using the defined $gist-renderer parameter

### method raku

```raku
method raku() returns Str
```

Returns a raku representation of the tree

### method reverse

```raku
method reverse() returns Tree::Binary::Role::Tree::Binary
```

Returns a new Tree::Binary where the node pairs have been swapped at each level

### method from-Str

```raku
method from-Str(
    Str $in
) returns Tree::Binary::Role::Tree::Binary
```

Object creation method using the Str coercion rules.

AUTHOR
======

Scimon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Scimon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

