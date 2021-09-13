unit package Tree::Binary;

use Tree::Binary::Enums;
use Tree::Binary::Role::HasNodes;

class Iterator does Iterator {
    has Tree::Binary::Role::HasNodes $!tree;
    has TraverseType $!traverse-type = InOrder;
    has TraverseDirection $!traverse-direction = LeftToRight;
    has @!nodes;

    method BUILD ( :$!tree, 
                   :$!traverse-type = InOrder, 
                   :$!traverse-direction = LeftToRight ) {
    }

    method TWEAK (|c) {
        @!nodes.unshift( $!tree );
    }

    method pull-one() {
        return IterationEnd unless @!nodes.elems; 
        my $next = @!nodes.shift;
        while ( $next ~~ Tree::Binary::Role::HasNodes ) {
            self!add-nodes( $next );
            $next = @!nodes.shift;
        }
        return $next;
    }

    method !add-nodes( $tree ) {
        my @children = $tree.?nodes // [];
        @children .=reverse if $!traverse-direction == RightToLeft;
        given $!traverse-type {
            when PreOrder {
                @!nodes.unshift($tree.value, |@children);
            }
            when PostOrder {
                @!nodes.unshift(|@children, $tree.value);
            }
            default {
                @!nodes.unshift(@children[1]) if @children.elems == 2;
                @!nodes.unshift($tree.?value // $tree);
                @!nodes.unshift(@children[0]) if @children;

            }
        }
    }

}
