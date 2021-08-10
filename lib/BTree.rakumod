use BTree::PrettyTree;
use BTree::Renderer;
use BTree::Grammar;

class BasicStrRenderer does BTree::Renderer {
    has BTree $.tree;

    method render {
        ( $.tree.value , |$.tree.nodes.map( { "({$_})" } ) ).join("");
    }
}

=begin pod

=head1 NAME

BTree - Simple Binary Tree Role with pretty printing

=head1 SYNOPSIS

=begin code :lang<raku>

use BTree;
class IntTree does BTree[Int] {};
my IntTree(Str) $tree = "1(2)(3)";
say $tree;

=end code

=begin code

 1 
┌┴┐
2 3

=end code

=head1 DESCRIPTION

BTree is intended to be a simple role that can be used to represent binary trees. 
It's intended to be a basis for a series of different types for trees. 

BTree's are immutable, classes that modify the tree should return a new tree
object.

=head2 BTree

=begin code :lang<raku>
role BTree[
    ::ValueType=Any,
    BTree::Renderer :$gist-renderer=BTree::PrettyTree,
    BTree::Renderer :$Str-renderer=BTree::PrettyTree,
]
=end code

The BTree C<Role> accepts one postional and two named parameters : 

=defn ValueType 
The type of object it should allow (defaulting to Any) 

=defn :$gist-renderer
An output renderer used for creating the BTree's gist representation. 
The default for this is BTree::PrettyTree  but any class that does 
BTree::Renderer will work.

=defn :$Str-renderer
An output renderer used for creating the BTree's Str representation. 
The default for this is BasicStrRenderer but any class that does 
BTree::Renderer will work.

=head3 Construction

The default constructor takes two named arguments :

=defn ValueType :$value
The value of the current node

=defn Array[BTree] :@nodes[2]
An array of 0-2 BTree nodes that are the children of the current node.

The role also allows for basic string coercion where a tree can be represented
with the following structure.

=begin code

value(node1)(node2)

=end code

Where C<value> is a C<Str> that can be coerced into a C<ValueType> and C<node1> 
and C<node2> another C<BTree> representation. The C<Str> method should produce
a value that can be coered into a BTree of the appropriate C<ValueType>.

=head3 Attributes

=end pod

role BTree:ver<0.0.1>:auth<zef:Scimon>[
    ::ValueType = Any, 
    BTree::Renderer :$gist-renderer = BTree::PrettyTree,
    BTree::Renderer :$Str-renderer  = BasicStrRenderer, 
] is export {

    #| The current nodes value
    has ValueType $.value is required;
    #| The child nodes
    has BTree @!nodes[2];

=begin pod

=head3 Methods

=end pod

    #| The child nodes of this node, undefined nodes will not be returned.
    method nodes(--> Array[BTree]) {
       my BTree @out = @!nodes.grep({defined $_});
    }

    submethod BUILD ( ValueType() :$value, :@nodes ) {
        $!value = $value;
        @!nodes = @nodes;
    }
    
    #|( Returns the number of defined nodes for the current node.
    Note that the elems method does NOT return the count of all nodes 
    in the tree just the current nodes children. 
    )
    method elems(--> UInt) {
        @.nodes.elems;
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
    
#    method traverse() {
#        gather {
#            if ( self.elems ) {
#                for @.nodes -> $n {
#                    for $n.traverse -> @t {
#                        take ($!value, |@t);
#                    }
#                }
#            } else {
#                take ( $!value, );
#            }
#        }
#    }
    
#    multi method reverse( ::?CLASS:D: ) {
#        self.new(
#            value => $!value,
#            nodes => @.nodes.reverse.map( *.reverse )
#        )
#    }
    
    method COERCE( Str:D $str --> BTree ) {
        return ::?CLASS.from-Str( $str );
    }

    multi method from-Str('') { BTree }
    
    multi method from-Str( ::?CLASS:U: Str $in ) {
        my $match = BTree::Grammar.parse( $in );
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
