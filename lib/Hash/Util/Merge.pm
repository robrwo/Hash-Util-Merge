package Hash::Util::Merge;

use v5.14;
use warnings;

use Exporter 5.57 ();
use List::Util 1.45 ();
use Sub::Util 1.45 ();

our $VERSION = 'v0.2.1';

# ABSTRACT: utility functions for merging hashes

=begin :prelude

=for stopwords Anwar

=end :prelude

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

  $hashref = mergemap { fn($a,$b) } \%a, \%b, \%c ...;

This returns a hash reference whose values are the result of repeatedly applying
a function to the values from all hashes, for each key.

The variables C<$a> and C<$b> refer to the value from the accumulator
(initialised to the first hash in the list) and the remaining hashes.

For example,

  my %a = ( x => 5, y => 6 );
  my %b = ( x => 2, y => 1 );

  my $c = mergemap { $a - $b } \%a, \%b;

Returns the hash reference

  ( x => 3, y => 5 );

If the hashes do not have the same set of keys, then C<$a> or C<$b>
will be C<undef> if the key is missing. (There is no means of
differentiating between a key that exists vs an C<undef> value.)

=cut

sub mergemap {

    my $pkg = caller;
    no strict 'refs'; ## no critic (ProhibitNoStrict)
    my $glob_a = \ *{"${pkg}::a"};
    my $glob_b = \ *{"${pkg}::b"};

    my $f = shift;
    my $x = shift // { };

    while (@_) {

        my $y = shift;

        my %r;
        for my $k ( List::Util::uniqstr( keys %$x, keys %$y ) ) {
            next if exists $r{$k};
            local *$glob_a = \$x->{$k};
            local *$glob_b = \$y->{$k};
            $r{$k} = $f->();
        }

        $x = \%r;

    }

    return $x;
}

BEGIN {
    Sub::Util::set_prototype '&@' => \&mergemap;
}

=head1 KNOWN ISSUES

L<Readonly> hashes, or those with locked keys, may return an error
when merged with a hash that has other keys.

=head1 SEE ALSO

L<Hash::Merge>

=head1 prepend:SUPPORT

Only the latest version of this module will be supported.

This module requires Perl v5.14 or later.

Future releases may only support Perl versions released in the last ten years.

=head2 Reporting Bugs and Submitting Feature Requests

=head1 append:SUPPORT

If the bug you are reporting has security implications which make it inappropriate to send to a public issue tracker,
then see F<SECURITY.md> for instructions how to report security vulnerabilities.

=head1 append:AUTHOR

This module uses code from L<List::Util::PP>.

This module was developed from work for Science Photo Library
L<https://www.sciencephoto.com>.

=cut

1;
