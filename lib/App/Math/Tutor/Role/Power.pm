package App::Math::Tutor::Role::Power;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::Power - role for power mathematics

=cut

use Moo::Role;
use App::Math::Tutor::Numbers;

our $VERSION = '0.004';

sub _check_power_to
{
    return $_[0]->basis != 0 and $_[0]->basis != 1;
}

has power_types => (
                     is => "lazy",
                   );

requires "format";

sub _build_power_types
{
    return [
        {
           name    => "power",
           numbers => 1,
           builder => sub { return int( rand( $_[0] ) + 1 ); },
        },
        {
           name    => "sqrt",
           numbers => 1,
           builder => sub {
               return
                 VulFrac->new( num   => 1,
                               denum => int( rand( $_[0] ) + 1 ) );
           },
        },
        {
           name    => "power+sqrt",
           numbers => 2,
           builder => sub {
               my $vf;
               do
               {
                   $vf = VulFrac->new( num   => int( rand( $_[0] ) + 1 ),
                                       denum => int( rand( $_[0] ) + 1 ) );
               } while ( !App::Math::Tutor::Role::VulFrac::_check_vulgar_fraction($vf) );
               return $vf;
           },
        },
    ];
}

sub _guess_power_to
{
    my ( $max_basis, $max_exponent ) = @{ $_[0]->format };
    my @types = @{ $_[0]->power_types };
    my $type  = int( rand( scalar @types ) );
    my ( $basis, $exponent ) =
      ( int( rand($max_basis) ), $types[$type]->{builder}->($max_exponent) );
    return
      Power->new(
                  basis    => $basis,
                  exponent => $exponent,
                  mode     => int( rand(2) )
                );
}

sub get_power_to
{
    my ( $self, $amount ) = @_;
    my @result;

    while ( $amount-- )
    {
        my $pt;
        do
        {
            $pt = $self->_guess_power_to;
        } while ( !_check_power_to($pt) );

        push @result, $pt;
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
