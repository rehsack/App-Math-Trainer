package App::Math::Tutor::Role::VulFrac;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::VulFrac - role for vulgar fraction numbers

=cut

use Moo::Role;
use MooX::Options;

our $VERSION = '0.003';

{
    package    #
      VulFrac;

    use Moo;
    use overload
      '""'   => \&_stringify,
      '0+'   => \&_numify,
      'bool' => sub { 1 },
      '<=>'  => \&_num_compare;

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has num => (
                 is       => "ro",
                 required => 1
               );

    has denum => (
                   is       => "ro",
                   required => 1
                 );

    sub _stringify
    {
        $_[0]->denum == 1 and return $_[0]->num;
        $_[1]
          and $_[0]->num > $_[0]->denum
          and return
          sprintf( '\normalsize{%d} \frac{%d}{%d}',
                   int( $_[0]->_numify ),
                   $_[0]->num - $_[0]->denum * int( $_[0]->_numify ),
                   $_[0]->denum );
        return "\\frac{" . $_[0]->num . "}{" . $_[0]->denum . "}";
    }

    sub _numify
    {
        my $rc = eval sprintf( "(%s)/(%s)", $_[0]->num, $_[0]->denum );
        $@ and croak $@;
        return $rc;
    }

    sub _num_compare
    {
        my ( $self, $other, $swapped ) = @_;
        $swapped and return $other <=> $self->_numify;

        blessed $other or return $self->_numify <=> $other;
        return $self->_numify <=> $other->_numify;
    }

    sub _euklid
    {
        my ( $a, $b ) = @_;
        my $h;
        while ( $b != 0 ) { $h = $a % $b; $a = $b; $b = $h; }
        return $a;
    }

    sub _gcd
    {
        my ( $a, $b ) = ( $_[0]->num, $_[0]->denum );
        my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
        return $gcd;
    }

    sub _reduce
    {
        my ( $a, $b ) = ( $_[0]->num, $_[0]->denum );
        my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
        return
          VulFrac->new( num   => $_[0]->num / $gcd,
                        denum => $_[0]->denum / $gcd );
    }

    sub _reciprocal
    {
        return
          VulFrac->new( num   => $_[0]->denum,
                        denum => $_[0]->num );
    }
}

sub _check_vulgar_fraction
{
    $_[0]->num >= 2 and $_[0]->denum >= 2 and $_[0]->num % $_[0]->denum != 0;
}

requires "format";

sub _guess_vulgar_fraction
{
    my ( $max_num, $max_denum ) = @{ $_[0]->format };
    my ( $num, $denum ) = ( int( rand($max_num) ), int( rand($max_denum) ) );
    return
      VulFrac->new( num   => $num,
                    denum => $denum );
}

sub get_vulgar_fractions
{
    my ( $self, $amount ) = @_;
    my @result;

    while ( $amount-- )
    {
        my $vf;
        do
        {
            $vf = $self->_guess_vulgar_fraction;
        } while ( !_check_vulgar_fraction($vf) );

        push @result, $vf;
    }

    return @result;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
