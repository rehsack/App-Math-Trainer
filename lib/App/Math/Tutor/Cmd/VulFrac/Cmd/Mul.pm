package App::Math::Tutor::Cmd::VulFrac::Cmd::Mul;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Tutor::Cmd::VulFrac::Cmd::Mul - Plugin for multiplication and division of vulgar fraction

=cut

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options;

has template_filename => (
                           is      => "ro",
                           default => "twocols"
                         );

with "App::Math::Tutor::Role::VulFracExercise";

sub _build_command_names
{
    return qw(mul div);
}

sub _build_exercises
{
    my ($self) = @_;

    my (@tasks);
    foreach my $i ( 1 .. $self->amount )
    {
        my @line;
        foreach my $j ( 0 .. 1 )
        {
            my ( $a, $b ) = $self->get_vulgar_fractions(2);
            push @line, [ $a, $b ];
        }
        push @tasks, \@line;
    }

    my $exercises = {
                     section => "Vulgar fraction multiplication / division",
                     caption => 'Fractions',
                     label   => 'vulgar_fractions_multiplication',
                     header => [ [ 'Vulgar Fraction Multiplication', 'Vulgar Fraction Division' ] ],
                     solutions  => [],
                     challenges => [],
                    };

    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );

        foreach my $i ( 0 .. 1 )
        {
            my ( $a, $b ) = @{ $line->[$i] };
            my $op = $i ? '\div' : '\cdot';
            push @challenge, sprintf( '$ %s %s %s = $', $a, $op, $b );

            my @way;    # remember Frank Sinatra :)
            push @way, sprintf( '%s %s %s', $a, $op, $b );

            ( $a, $b ) = ( $a->_reduce, $b = $b->_reduce );
            push @way, sprintf( '%s %s %s', $a, $op, $b )
              if ( $a->num != $line->[$i]->[0]->num or $b->num != $line->[$i]->[1]->num );

            my $s;
            unless ($i)
            {
                # multiplication
                push @way,
                  sprintf( '\frac{%d \cdot %d}{%d \cdot %d}',
                           $a->num, $b->num, $a->denum, $b->denum );
                $s = VulFrac->new( num   => $a->num * $b->num,
                                   denum => $a->denum * $b->denum );
            }
            else
            {
                #division
                push @way,
                  sprintf( '\frac{%d \cdot %d}{%d \cdot %d}',
                           $a->num, $b->denum, $b->num, $a->denum );
                $s = VulFrac->new( num   => $a->num * $b->denum,
                                   denum => $b->num * $a->denum );
            }
            push @way, "" . $s;
            my $c = $s->_reduce;
            $c->num != $s->num and push @way, "" . $c;

            $c->num > $c->denum and $c->denum > 1 and push @way, $c->_stringify(1);

            push( @solution, '$ ' . join( " = ", @way ) . ' $' );
        }

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
