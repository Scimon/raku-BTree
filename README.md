[![Actions Status](https://github.com/Scimon/raku-BTree/workflows/test/badge.svg)](https://github.com/Scimon/raku-BTree/actions)

NAME
====

BTree - Simple Binary Tree Role with pretty printing

SYNOPSIS
========

```raku
use BTree;
class IntTree does BTree[Int] {};
my IntTree(Str) $tree = "1(2)(3)";
say $tree;
```

     1 
    ┌┴┐
    2 3

DESCRIPTION
===========

BTree is intended to be a simple role that can be used to represent binary trees. It's intended to be a basis for a series of different types for trees. 

BTree's are immutable, classes that modify the tree should return a new tree object.

BTree
-----

```raku
role BTree[
    ::ValueType=Any,
    BTree::Renderer :$gist-renderer=BTree::PrettyTree,
    BTree::Renderer :$Str-renderer=BTree::PrettyTree,
]
```

The BTree `Role` accepts one postional and two named parameters : 

**ValueType**

The type of object it should allow (defaulting to Any)

**:$gist-renderer**

An output renderer used for creating the BTree's gist representation. The default for this is BTree::PrettyTree but any class that does BTree::Renderer will work.

**:$Str-renderer**

An output renderer used for creating the BTree's Str representation. The default for this is BasicStrRenderer but any class that does BTree::Renderer will work.

### Construction

The default constructor takes two named arguments :

**ValueType :$value**

The value of the current node

**Array[BTree] :@nodes[2]**

An array of 0-2 BTree nodes that are the children of the current node.

The role also allows for basic string coercion where a tree can be represented with the following structure.

    value(node1)(node2)

Where `value` is a `Str` that can be coerced into a `ValueType` and `node1` and `node2` another `BTree` representation. The `Str` method should produce a value that can be coered into a BTree of the appropriate `ValueType`.

### Attributes

### has ValueType $.value

The current nodes value

### has Positional[BTree] @!nodes

The child nodes

### Methods

### method nodes

```raku
method nodes() returns Array[BTree]
```

The child nodes of this node, undefined nodes will not be returned.

### method elems

```raku
method elems() returns UInt
```

Returns the number of defined nodes for the current node. Note that the elems method does NOT return the count of all nodes in the tree just the current nodes children.

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

AUTHOR
======

Scimon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Scimon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

