package Hash::Util::Merge;

use v5.14;
use warnings;

use Exporter 5.57 ();
use Sub::Util 1.40 qw( set_prototype );

our $VERSION = 'v0.2.0';

# ABSTRACT: utility functions for merging hashes

=head1 SYNOPSIS

  use Hash::Util::Merge qw/ mergemap /;

  my %a = ( x => 1, y => 2 );
  my %b = ( x => 3, y => 7 );

  my $c = mergemap { $a + $b } \%a, \%b;

  # %c = ( x => 4, y => 9 );

=head1 DESCRIPTION

This module provides some syntactic sugar for merging simple
hashes with a function.

=head1 prepend:EXPORTS

None by default.

=cut

our @EXPORT_OK = qw/ mergemap /;

sub import {

    # This borrows a technique from List::Util that exports symbols $a
    # and $b to the callers namespace, so that function arguments can
    # simply use $a and $b, akin to how function arguments for sort
    # works.

    my $pkg = caller;
    no strict 'refs'; ## no critic (ProhibitNoStrict)
    ${"${pkg}::a"} = ${"${pkg}::a"};
    ${"${pkg}::b"} = ${"${pkg}::b"};
    goto &Exporter::import;
}

=export mergemap

  $hashref = mergemap { fn($a,$b) } \%a, \%b;

For each key in the hashes C<%a> and C<%b>, this function applies the
user-supplied function C<fn> to the corresponding values of that key,
in the resulting hash reference.

If a key does not exist in either of the hashes, then it will return
C<undef>.

=cut

sub mergemap {

    my $pkg = caller;
    no strict 'refs'; ## no critic (ProhibitNoStrict)
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

BEGIN {
    set_prototype '&$$' => \&mergemap;
}

=head1 SUPPORT FOR OLDER PERL VERSIONS

Since v0.2.0, the this module requires Perl v5.14 or later.

Future releases may only support Perl versions released in the last ten years.

If you need this module on Perl v5.10, please use one of the v0.1.x
versions of this module.  Significant bug or security fixes may be
backported to those versions.

=head1 KNOWN ISSUES

L<Readonly> hashes, or those with locked keys, may return an error
when merged with a hash that has other keys.

=head1 SEE ALSO

L<Hash::Merge>

=head1 append:AUTHOR

This module uses code from L<List::Util::PP>.

This module was developed from work for Science Photo Library
L<https://www.sciencephoto.com>.

=cut

1;
