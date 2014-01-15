package App::Math::Tutor::Role::Natural;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::Natural - role for natural numbers

=cut

use Moo::Role;

our $VERSION = '0.003';

{
    package    #
      NatNum;

    use Moo;
    use overload
      '""'   => "_stringify",
      '0+'   => "_numify",
      'bool' => sub { 1 },
      '<=>'  => "_num_compare";

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has value => (
                   is       => "ro",
                   required => 1
                 );

    sub _stringify { "" . $_[0]->value }
    sub _numify    { $_[0]->value }

    sub _num_compare
    {
        my ( $self, $other, $swapped ) = @_;
        $swapped and return $other <=> $self->_numify;

        blessed $other or return $self->_numify <=> $other;
        return $self->_numify <=> $other->_numify;
    }
}

sub _check_natural_number { return $_[0]->value >= 2 }

requires "format";

sub _guess_natural_number
{
    my $max_val = $_[0]->format;
    my $value   = int( rand($max_val) );
    return NatNum->new( value => $value );
}

sub get_natural_number
{
    my ( $self, $amount ) = @_;
    my @result;

    while ( $amount-- )
    {
        my $nn;
        do
        {
            $nn = $self->_guess_natural_number;
        } while ( !_check_natural_number($nn) );

        push @result, $nn;
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
