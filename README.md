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

DESCRIPTION
===========

BTree is intended to be a simple role that can be used to represent binary trees. It's intended to be a basis for a series of different types for trees. 

AUTHOR
======

Scimon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Scimon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

