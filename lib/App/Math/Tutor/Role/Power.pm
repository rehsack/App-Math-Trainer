package App::Math::Tutor::Role::Power;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::Power - role for power mathematics

=cut

use Moo::Role;
use MooX::Options;

use Module::Runtime qw/require_module/;

our $VERSION = '0.003';

require_module 'App::Math::Tutor::Role::VulFrac';    # we only want VulFrac type

{
    package                                            #
      Power;

    use Moo;
    use overload
      '""'   => \&_stringify,
      '0+'   => \&_numify,
      'bool' => sub { 1 },
      '<=>'  => \&_num_compare;

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has basis => (
                   is       => "ro",
                   required => 1
                 );

    has exponent => (
                      is       => "ro",
                      required => 1
                    );

    has mode => (
                  is      => "rw",
                  default => sub { 0 },
                );

    sub _stringify
    {
        $_[0]->exponent == 1 and return $_[0]->basis;
        $_[0]->mode or return join( "^", $_[0]->basis, $_[0]->exponent );
        return
          sprintf( "\\sqrt[%s]{%s}",
                   blessed( $_[0]->exponent ) ? $_[0]->exponent->denum : $_[0]->exponent,
                   blessed( $_[0]->exponent )
                     && $_[0]->exponent->num > 1
                   ? sprintf( "{%s}^{%s}", $_[0]->basis, $_[0]->exponent->num )
                   : $_[0]->basis );
    }

    sub _numify
    {
        my $rc = eval sprintf( "(%d)**(%d)", $_[0]->basis, $_[0]->exponent );
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

    sub _reduce
    {
        die "mising";
    }
}

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
