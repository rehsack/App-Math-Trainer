package App::Math::Trainer::Role::DecFrac;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer::Role::DecFrac - role for decimal fraction numbers

=cut

use Moo::Role;
use MooX::Options;

our $VERSION = '0.003';

requires "range", "digits";

sub _check_decimal_fraction
{
    my $self = shift;
    my ( $minr, $minc, $maxr, $maxc ) = @{ $self->range };
    my $digits = $self->digits;
    $digits += length( "" . int( $_[0] ) ) + 1;
    my $s1 = sprintf( "%.${digits}g", $_[0] );

    return (     $minc->( $minr, $_[0] )
             and $maxc->( $maxr, $_[0] )
             and $s1 == $_[0]
             and length($s1) >= 3 );
}

1;
