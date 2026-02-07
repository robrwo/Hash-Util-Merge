use Test::Most;
use Test::Warnings;

use Hash::Util::Merge qw/ mergemap /;

my %a = ( a => 10, b => 15 );
my %b = ( a => 1,  b => 5 );
my %c = ( b => 4 );

{
    my $c = mergemap { $a + $b } \%a, \%b;
    is_deeply $c, { a => 11, b => 20 }, 'mergemap';
}

{
    my $c = mergemap { $a - $b } \%a, \%b;
    is_deeply $c, { a => 9, b => 10 }, 'mergemap';
}

{
    my $c = mergemap { $a + ($b // 1) } \%a, \%c;
    is_deeply $c, { a => 11, b => 19 }, 'mergemap (undef)';
}

{
    my $c = mergemap { $a // $b } \%c, \%a;
    is_deeply $c, { a => $a{a}, b => $c{b} }, 'mergemap (undef)';
}

{
    my $c = mergemap { $a + $b } \%a;
    is_deeply $c, \%a, 'mergemap (single argument)';
}

{
    my $c = mergemap { $a + $b };
    is_deeply $c, { }, 'mergemap (no argument)';
}

{
    my $c = mergemap { $a + $b // 0 } \%a, \%b, { a => 4, b => 7 };
    is_deeply $c, { a => 15, b => 27 }, 'mergemap (three args)';
}

{
    my $c = mergemap { $a + ( $b // 0 ) } \%a, \%b, { a => 4, b => 7 }, { a => 0, %c };
    is_deeply $c, { a => 15, b => 31 }, 'mergemap (four args)';
}

{
    my @list = ( \%a, \%b );
    my $c    = mergemap { $a + $b } @list;
    is_deeply $c, { a => 11, b => 20 }, 'mergemap (list)';
}


done_testing;
