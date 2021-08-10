use BTree::PrettyTree;
use BTree::Grammar;

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

=head2 BTree

=begin code :lang<raku>
role BTree[::ValueType=Any,BTree::Renderer :$gist-renderer=BTree::PrettyTree]
=end code

The BTree C<Role> accepts two parameters : 

=defn ValueType
The type of object it should allow (defaulting to Any) 

=defn :$gist-renderer
An output renderer used for creating the BTree's gist representation. 
The default for this is BTree::PrettyTree  but any class that does 
BTree::Renderer will work.

=end pod

role BTree:ver<0.0.1>:auth<zef:Scimon>[
    ::ValueType = Any, #= Node value type
    BTree::Renderer :$gist-renderer =BTree::PrettyTree #= Output generator for c<gist>
] is export {

    has ValueType $.value is required;
    has BTree @!nodes[2];
    
    submethod BUILD ( ValueType() :$value, :@nodes ) {
        $!value = $value;
        @!nodes = @nodes;
    }
    
    #| Returns a Str representation of the tree. 
    method Str(--> Str ) {
        ( $!value , |@.nodes.map( { "({$_})" } ) ).join("");
    }
    
    method COERCE( Str:D $str --> BTree ) {
        return ::?CLASS.from-Str( $str );
    }
    
    method nodes() {
        @!nodes.grep({defined $_});
    }
    
    method children() {
        @.nodes.elems;
    }
    
    method gist() {
        $gist-renderer.new( tree=>self ).render();
    }
    
    method raku() {
        "{self.^name}.new( {("value => {$!value}", self.nodes ?? "nodes => {(self.nodes.map(*.raku)).join(", ")}" !! Empty).join(", ")} )";
    }
    
    method traverse() {
        gather {
            if ( self.children ) {
                for @.nodes -> $n {
                    for $n.traverse -> @t {
                        take ($!value, |@t);
                    }
                }
            } else {
                take ( $!value, );
            }
        }
    }
    
    multi method reverse( ::?CLASS:D: ) {
        self.new(
            value => $!value,
            nodes => @.nodes.reverse.map( *.reverse )
        )
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
