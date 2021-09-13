unit package Tree::Binary;

use Tree::Binary::Enums;
use Tree::Binary::Role::HasNodes;

class Iterator does Iterator {
    has Tree::Binary::Role::HasNodes $!tree;
    has TraverseType $!traverse-type = DepthFirst;
    has TraverseDirection $!traverse-direction = LeftToRight;
    has @!nodes;

    method BUILD ( :$!tree, 
                   :$!traverse-type = DepthFirst, 
                   :$!traverse-direction = LeftToRight ) {
    }

    method TWEAK (|c) {
        @!nodes.unshift( $!tree );
    }

    method pull-one() {
        return IterationEnd unless @!nodes.elems; 
        my $tree =  @!nodes.shift;
        self!add-nodes( $tree );
        return $tree.value;
    }

    method !add-nodes( $tree ) {
        my @children = $tree.nodes;
        @children .=reverse if $!traverse-direction == RightToLeft;
        given $!traverse-type {
            when DepthFirst {
                @!nodes.unshift(|@children);
            }
            when BreadthFirst {
                @!nodes.push(|@children);
            }
        }
    }

}
