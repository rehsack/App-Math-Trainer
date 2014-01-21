package App::Math::Tutor::Cmd::Poly::Cmd::Solve;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Tutor::Cmd::Poly::Cmd::Solve - Plugin for solving polynoms

=cut

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options;

use Carp qw(croak);

has template_filename => (
                           is      => "ro",
                           default => "onecolmlsol"
                         );
use Module::Runtime qw/require_module/;

require_module 'App::Math::Tutor::Role::VulFrac';    # we only want VulFrac type

with "App::Math::Tutor::Role::PolyExercise";

sub _get_quad_solution
{
    my ( $self, $poly ) = @_;
    my ( @orig, @way, @solution );
    push @orig, "$poly";

    my @values = @{ $poly->values };
    my @rvalues;
    my @pqvalues;
    my $reduced = 0;
    my $a_f     = $values[-1]->[0];
    my ( $p, $q ) = (0, 0);
    foreach my $i ( 0 .. $#values - 1 )
    {
        my $exp = $values[$i][1];
        my $f = VulFrac->new( num   => $values[$i][0],
                              denum => $a_f );
        push( @pqvalues, [ $f, $exp ] );
        $f->_gcd and ++$reduced and $f = $f->_reduce;
        push( @rvalues, [ $f, $exp ] );
        0 == $exp and $q = $f;
        1 == $exp and $p = $f;
    }
    push( @pqvalues, [ 1, $values[-1]->[1] ] );
    push( @rvalues, [ 1, $values[-1]->[1] ] );
    $reduced and push @orig, PolyNum->new( values => \@pqvalues );
    push( @orig, PolyNum->new( values => \@rvalues ) );

    push( @solution, '$ ' . join( " = ", @orig ) . ' $' );

    push @way, "X_{1/2}";
    push @way, sprintf( '-\frac{%s}{2} + \sqrt{\frac{(%s)^2}{4} - %s}', $p, $p, $q );

    push( @solution, '$ ' . join( " = ", @way ) . ' $' );

    return @solution;
}

sub _build_exercises
{
    my ($self) = @_;

    my (@tasks);

    foreach my $i ( 1 .. $self->amount )
    {
	my @line;
        push @line,  $self->get_polynom(1);
        push @tasks, \@line;
    }

    my $exercises = {
                      section    => "Polynom Solving",
                      caption    => 'Polynoms',
                      label      => 'polynom_solving',
                      header     => [ ['Polynom Solve'] ],
                      solutions  => [],
                      challenges => [],
                    };

    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );

        my ($a) = @{$line};
        push( @challenge, "\$ $a = 0 \$" );
        $a->values->[-1]->[1] > 2 and die "No way to solve polynoms of power 3 or higher";
        $a->values->[-1]->[1] == 2 and push @solution, $self->_get_quad_solution($a);

        push( @{ $exercises->{solutions} },  \@solution );
        push( @{ $exercises->{challenges} }, \@challenge );
    }

    return $exercises;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
