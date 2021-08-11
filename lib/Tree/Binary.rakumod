unit package Tree;

use Tree::Binary::PrettyTree;
use Tree::Binary::Role::Renderer;
use Tree::Binary::Grammar;

class BasicStrRenderer does Tree::Binary::Role::Renderer {
    has Tree::Binary $.tree;

    method render {
        ( $.tree.value , |$.tree.nodes.map( { "({$_})" } ) ).join("");
    }
}

=begin pod

=head1 NAME

Tree::Binary - Simple Binary Tree Role with pretty printing

=head1 SYNOPSIS

=begin code :lang<raku>

use Tree::Binary;
class IntTree does Tree::Binary[Int] {};
my IntTree(Str) $tree = "1(2)(3)";
say $tree;

=end code

=begin code

 1 
┌┴┐
2 3

=end code

=head1 DESCRIPTION

Tree::Binary is intended to be a simple role that can be used to represent binary 
trees. It's intended to be a basis for a series of different types for trees. 

Tree::Binary does not include code for inserting or deleting nodes as this is 
dependent on the concreate class using it. 

=head2 Tree::Binary

=begin code :lang<raku>
role Tree::Binary[
    ::ValueType=Any,
    Tree::Binary::Role::Renderer :$gist-renderer=Tree::Binary::PrettyTree,
    Tree::Binary::Role::Renderer :$Str-renderer=BasicStrRenderer,
]
=end code

The Tree::Binary C<Role> accepts one postional and two named parameters : 

=defn ValueType 
The type of object it should allow (defaulting to Any) 

=defn :$gist-renderer
An output renderer used for creating the Tree::Binary's gist representation. 
The default for this is Tree::Binary::PrettyTree  but any class that does 
Tree::Binary::Role::Renderer will work.

=defn :$Str-renderer
An output renderer used for creating the Tree::Binary's Str representation. 
The default for this is BasicStrRenderer but any class that does 
Tree::Binary::Role::Renderer will work.

=head3 Construction

The default constructor takes two named arguments :

=defn ValueType :$value
The value of the current node

=defn Array[Tree::Binary] :@nodes[2]
An array of 0-2 Tree::Binary nodes that are the children of the current node.

The role also allows for basic string coercion where a tree can be represented
with the following structure.

=begin code

value(node1)(node2)

=end code

Where C<value> is a C<Str> that can be coerced into a C<ValueType> and C<node1> 
and C<node2> another C<Tree::Binary> representation. The C<Str> method should produce
a value that can be coered into a Tree::Binary of the appropriate C<ValueType>.

Alternate construction options using C<Str> coercion are :

=begin code :lang<raku>

# Coercion from a Str to a Tree::Binary
my Tree::Binary(Str) $tree1 = "1(a)(£)";

# Using the from-Str constructor
my $tree2 = Tree::Binary.from-Str("1(a)(£)");

=end code

=head3 Attributes

=end pod

role Binary:ver<0.0.3>:auth<zef:Scimon>[
    ::ValueType = Any, 
    Tree::Binary::Role::Renderer :$gist-renderer = PrettyTree,
    Tree::Binary::Role::Renderer :$Str-renderer  = BasicStrRenderer, 
] is export {

    #| The current nodes value
    has ValueType $.value is required;
    #| The child nodes
    has Tree::Binary @!nodes[2];

=begin pod

=head3 Methods

=end pod

    #| The child nodes of this node, undefined nodes will not be returned.
    method nodes(--> Array[Tree::Binary]) {
       my Tree::Binary @out = @!nodes.grep({defined $_});
    }

    submethod BUILD ( ValueType() :$value, :@nodes ) {
        $!value = $value;
        @!nodes = @nodes;
    }
    

    #|( Returns the number of defined nodes for the current node.
    Note that the elems method does NOT return the count of all nodes 
    in the tree just the current nodes children. 
    )
    multi method elems(--> UInt) {
        @.nodes.elems;
    }

    multi method elems( Bool :$leaf!, Bool :$all! --> UInt ) {
        die "The :all and :leaf flags in elems are incompatible";
    }

    #|( With the :all flag returns the total number of nodes in the tree 
    including the current one but not any undefined ones.
    )
    multi method elems( Bool :$all! --> UInt ) {
        [+] 1, |self.nodes().map( *.elems(:all) );
    }

    #|( With the :leaf flag returns the total number of leaf nodes )
    multi method elems( Bool :$leaf! --> UInt ) {
        given self.nodes.elems {
            when 0 {
                return 1;
            }
            default {
                return [+] |self.nodes().map( *.elems(:leaf) );
            }
        }
    }

    #| Returns a Str representation of the tree using the :$Str-renderer parameter 
    method Str(--> Str ) {
        $Str-renderer.new( tree=>self ).render();
    }

    #| Returns the gist for this tree using the defined $gist-renderer parameter
    method gist(--> Str) {
        $gist-renderer.new( tree=>self ).render();
    }
    
    #| Returns a raku representation of the tree
    method raku(--> Str) {
        "{self.^name}.new( {("value => {$!value}", self.nodes ?? "nodes => {(self.nodes.map(*.raku)).join(", ")}" !! Empty).join(", ")} )";
    }

    method routes() {
        gather {
            if ( self.elems ) {
                for @.nodes -> $n {
                    for $n.routes -> @t {
                        take ($!value, |@t);
                    }
                }
            } else {
                take ( $!value, );
            }
        }
    }
    
    #|( Returns a new Tree::Binary where the node pairs have been swapped at each level )
    multi method reverse( ::?CLASS:D: --> Tree::Binary ) {
        self.new(
            value => $!value,
            nodes => @.nodes.reverse.map( *.reverse )
        )
    }

    multi method reverse( ::?CLASS:U: ) { Tree::Binary }
    
    method COERCE( Str:D $str --> Tree::Binary ) {
        return ::?CLASS.from-Str( $str );
    }

    multi method from-Str('' --> Tree::Binary ) { Tree::Binary }
    
    #| Object creation method using the Str coercion rules.
    multi method from-Str( ::?CLASS:U: Str $in --> Tree::Binary ) {
        my $match = Tree::Binary::Grammar.parse( $in );
        if ( $match ) {
            self.new(
                value => $match<tree><value>.Str,
                nodes => [
                          self.from-Str( $match<tree><left> ?? $match<tree><left>.Str !! '' ),
                          self.from-Str( $match<tree><right> ?? $match<tree><right>.Str !! '' )
                      ]
            );
        } else {
            die "Unable to Parse $in";
        }
        
    }

}

=begin pod

=head1 AUTHOR

Scimon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Scimon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
