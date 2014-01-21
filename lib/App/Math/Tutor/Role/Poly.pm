package App::Math::Tutor::Role::Poly;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::Poly - role for polynoms

=cut

use Moo::Role;

our $VERSION = '0.004';

{
    package    #
      PolyNum;

    use Moo;
    use overload
      '""'   => "_stringify",
      'bool' => sub { 1 };

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has values => (
                    is       => "ro",
                    required => 1
                  );

    sub _stringify_term
    {
	my ($self, $fact, $exp) = @_;
	$fact or return;
	0 == $exp and return "$fact";
	1 == $exp and 1 != $fact and return "{$fact}x";
	1 == $exp and return "x";
	1 == $fact and return "x^{$exp}";
	return sprintf("{%s}x^{%s}", $fact, $exp);
    }

    sub _stringify
    {
	my $self = $_[0];
        join( "+", grep { defined $_ } ( map { $self->_stringify_term(@{$_}) } reverse @{ $_[0]->values } ));
    }
}

sub _check_polynom { $_[1]->values->[-1]->[1] == $_[0]->max_power; }

requires "max_power";

sub _guess_polynom
{
    my $probability = $_[0]->probability;
    my $max_val     = $_[0]->format;
    my @values;
    foreach my $exp ( 0 .. $_[0]->max_power )
    {
        my $likely = rand(100);
        $likely <= $probability or next;
        my $value = int( rand($max_val) );
        push @values, [ $value, $exp ];
    }
    return PolyNum->new( values => \@values );
}

sub get_polynom
{
    my ( $self, $amount ) = @_;
    my @result;

    while ( $amount-- )
    {
        my $nn;
        do
        {
            $nn = $self->_guess_polynom;
        } while ( !$self->_check_polynom($nn) );

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
