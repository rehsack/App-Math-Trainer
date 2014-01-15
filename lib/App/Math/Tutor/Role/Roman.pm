package App::Math::Tutor::Role::Roman;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::Roman - role for roman style natural numbers

=cut

use Moo::Role;

with "App::Math::Tutor::Role::Natural";

our $VERSION = '0.003';

{
    package    #
      RomanNum;

    use Moo;

    extends "NatNum";

    use Carp qw/croak/;

    around BUILDARGS => sub {
        my $next   = shift;
        my $class  = shift;
        my $params = $class->$next(@_);
        defined $params->{value}
          and $params->{value} < 1
          and croak( "Roman numerals starts at I - " . $params->{value} . " is to low" );
        defined $params->{value}
          and $params->{value} > 3888
          and
          croak( "Roman numerals ends at MMMDCCCLXXXVIII - " . $params->{value} . " is to big" );
        return $params;
    };

    my %sizes = (
                  M  => 1000,
                  CM => 900,
                  D  => 500,
                  CD => 400,
                  C  => 100,
                  XC => 90,
                  L  => 50,
                  XL => 40,
                  X  => 10,
                  IX => 9,
                  V  => 5,
                  IV => 4,
                  I  => 1,
                );

    sub _stringify
    {
        my $self  = $_[0];
        my $value = $self->value;
        my $str   = "";
        my @order = sort { $sizes{$b} <=> $sizes{$a} } keys %sizes;
        foreach my $sym (@order)
        {
            while ( $value >= $sizes{$sym} )
            {
                $str .= $sym;
                $value -= $sizes{$sym};
            }
        }
        return $str;
    }
}

around _guess_natural_number => sub {
    my $next    = shift;
    my $max_val = $_[0]->format;
    my $value   = int( rand( $max_val - 1 ) ) + 1;
    return RomanNum->new( value => $value );
};

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
