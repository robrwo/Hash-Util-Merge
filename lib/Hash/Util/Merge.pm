package Hash::Util::Merge;

use v5.22;
use warnings;

use Exporter ();

our @EXPORT_OK = qw/ mergemap /;

sub import {

    # This borrows a technique from List::Util that exports symbols $a
    # and $b to the callers namespace, so that function arguments can
    # simply use $a and $b, akin to how function arguments for sort
    # works.

    my $pkg = caller;
    no strict 'refs';
    ${"${pkg}::a"} = ${"${pkg}::a"};
    ${"${pkg}::b"} = ${"${pkg}::b"};
    goto &Exporter::import;
}

sub mergemap(&$$) {

    my $pkg = caller;
    no strict 'refs';
    my $glob_a = \ *{"${pkg}::a"};
    my $glob_b = \ *{"${pkg}::b"};

    my ($f, $x, $y) = @_;

    my %r;

    for my $k (keys %$x, keys %$y) {
        next if exists $r{$k};
        local *$glob_a = \ $x->{$k};
        local *$glob_b = \ $y->{$k};
        $r{$k} = $f->();
    }

    return \%r;
}

1;
