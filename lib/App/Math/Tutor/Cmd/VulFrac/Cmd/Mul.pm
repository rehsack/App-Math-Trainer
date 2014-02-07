package App::Math::Tutor::Cmd::VulFrac::Cmd::Mul;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Tutor::Cmd::VulFrac::Cmd::Mul - Plugin for multiplication and division of vulgar fraction

=cut

our $VERSION = '0.004';

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
    foreach my $i ( 1 .. $self->quantity )
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

    my $a_mult_b = sub {
        return
          ProdNum->new( operator => $_[0],
                        values   => [ splice @_, 1 ] );
    };

    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );

        foreach my $i ( 0 .. 1 )
        {
            my ( $a, $b ) = @{ $line->[$i] };
            my $op = $i ? '/' : '*';
            push @challenge, sprintf( '$ %s = $', $a_mult_b->( $op, $a, $b ) );

            my @way;    # remember Frank Sinatra :)
            push @way, $a_mult_b->( $op, $a, $b );

            ( $a, $b ) = ( $a->_reduce, $b = $b->_reduce ) and push @way, $a_mult_b->( $op, $a, $b )
              if ( $a->_gcd > 1 or $b->_gcd > 1 );

            if ($i)
            {
                $b  = $b->_reciprocal;
                $op = '*';
                push @way, $a_mult_b->( $op, $a, $b );
            }

            my $s = VulFrac->new(
                                num   => $a_mult_b->( $op, $a->sign * $a->num, $b->sign * $b->num ),
                                denum => $a_mult_b->( $op, $a->denum,          $b->denum ) );
            push @way, $s;
            $s = VulFrac->new(
                               num   => int( $s->num ),
                               denum => int( $s->denum ),
                               sign  => $s->sign
                             );
            push @way, $s;

            $s->_gcd > 1 and $s = $s->_reduce and push @way, $s;

            $s->num > $s->denum and $s->denum > 1 and push @way, $s->_stringify(1);

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
