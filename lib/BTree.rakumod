use BTree::PrettyTree;
use BTree::Grammar;

role BTree:ver<0.0.1>:auth<zef:Scimon>[::T=Any,::R=BTree::PrettyTree] is export {

    has T $.value is required;
    has BTree @!nodes[2];
    
    submethod BUILD ( T() :$value, :@nodes ) {
        $!value = $value;
        @!nodes = @nodes;
    }
    
    method Str( ) {
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
        R.new( tree=>self ).gist();
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

=head1 NAME

BTree - Simple Binary Tree Role with pretty printing

=head1 SYNOPSIS

=begin code :lang<raku>

use BTree;
class IntTree does BTree[Int] {};
my IntTree(Str) $tree = "1(2)(3)";
say $tree;

=end code

=head1 DESCRIPTION

BTree is intended to be a simple role that can be used to represent binary trees. It's intended to be a basis for
a series of different types for trees. 

=head1 AUTHOR

Scimon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Scimon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
