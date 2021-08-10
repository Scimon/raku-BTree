use BTree::Renderer;

role BTree {...}

class BTree::PrettyTree does BTree::Renderer {

    has @.data;
    has UInt $.join-point;

    multi submethod BUILD ( BTree :$tree where { ! $tree.children } ) {
        @!data = [$tree.value.Str];
        $!join-point = $tree.value.Str.codes div 2;
    }
    
    multi submethod BUILD ( BTree :$tree ) {
        my ( $left, $right, $left-width, $right-width );
        my ( @ldata, @rdata, $left-pad, $right-pad );
        
        my $mid-string = '┘';
        $left = BTree::PrettyTree.new( tree => $tree.nodes[0] );
        $left-width = $left.data[0].codes;
        @ldata = $left.data;
        @ldata.unshift( (" " x $left.join-point) ~ "┌" ~ ("─" x ($left-width - 1 - $left.join-point) ) );
        
        if ( $tree.children == 2 ) {
            my $right = BTree::PrettyTree.new( tree => $tree.nodes[1] );
            $mid-string = '┴';
            @rdata = $right.data;
            $right-width = @rdata[0].codes;
            @rdata.unshift( ( "─" x ( $right.join-point ) ~ '┐' ~ ( " " x $right-width - 1 - $right.join-point ) ) );
        } else {
            $right-width = 1;
            @rdata = @ldata.map( { " " } );
        }
        
        if ( $left-width + $right-width + 1 < $tree.value.codes ) {
            $left-pad = 0;
            $right-pad = 0;
            my $extra = $tree.value.codes - ($left-width + $right-width + 1);
            @ldata = @ldata.map( { ( " " x ( $extra div 2 ) ) ~ $_ } );
            @rdata = @rdata.map( { $_ ~ ( " " x ( $extra div 2 + $extra % 2 ) ) } );
        } else {
            $left-pad = $left-width - ($tree.value.codes div 2);
            $right-pad = ($left-width + $right-width + 1) - $left-pad - $tree.value.codes;
        }
        my $top = ( " " x $left-pad ) ~ $tree.value ~ ( " " x $right-pad );
        my $left-fill = gather { for @ldata.elems^..@rdata.elems { take " " x $left-width } };
        my $right-fill = gather { for @rdata.elems^..@ldata.elems { take " " x $right-width } };
        
        @!data = $top, |( ( (|@ldata, |$left-fill) Z, (|@rdata, |$right-fill) ).map( { state $i=0;$_.join($i++??" "!!$mid-string) } ) );
        $!join-point = $left-pad + ( $tree.value.Str.codes div 2);
    }
    
    method gist {
        @.data.join("\n");
    }
}
