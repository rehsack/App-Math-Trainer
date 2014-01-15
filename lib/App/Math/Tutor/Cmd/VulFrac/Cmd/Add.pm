package App::Math::Tutor::Cmd::VulFrac::Cmd::Add;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Tutor::Cmd::VulFrac::Cmd::Add - Plugin for addition and subtraction of vulgar fractions

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
    return qw(add sub);
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
                      section => "Vulgar fraction addition / subtraction",
                      caption => 'Fractions',
                      label   => 'vulgar_fractions_addition',
                      header  => [ [ 'Vulgar Fraction Addition', 'Vulgar Fraction Subtraction' ] ],
                      solutions  => [],
                      challenges => [],
                    };

    # use Text::TabularDisplay;
    # my $table = Text::TabularDisplay->new( 'Bruch -> Dez', 'Dez -> Bruch' );
    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );

        foreach my $i ( 0 .. 1 )
        {
            my ( $a, $b ) = @{ $line->[$i] };
            my $op = $i ? '-' : '+';
            $op eq '-' and $a < $b and ( $b, $a ) = ( $a, $b );
            push @challenge, sprintf( '$ %s %s %s = $', $a, $op, $b );

            my @way;    # remember Frank Sinatra :)
            push @way, sprintf( '%s %s %s', $a, $op, $b );

            ( $a, $b ) = ( $a->_reduce, $b = $b->_reduce );
            push @way, sprintf( '%s %s %s', $a, $op, $b )
              if ( $a->num != $line->[$i]->[0]->num or $b->num != $line->[$i]->[1]->num );

            my $gcd = VulFrac->new(
                                    num   => $a->denum,
                                    denum => $b->denum
                                  )->_gcd;
            my ( $fa, $fb ) = ( $b->{denum} / $gcd, $a->{denum} / $gcd );

            push @way,
              sprintf( '\frac{%d \cdot %d}{%d \cdot %d} %s \frac{%d \cdot %d}{%d \cdot %d}',
                       $a->num, $fa, $a->denum, $fa, $op, $b->num, $fb, $b->denum, $fb );
            push @way,
              sprintf( '\frac{%d}{%d} %s \frac{%d}{%d}',
                       $a->num * $fa,
                       $a->denum * $fa,
                       $op,
                       $b->num * $fb,
                       $b->denum * $fb );
            push @way,
              sprintf( '\frac{%d %s %d}{%d}', $a->num * $fa, $op, $b->num * $fb, $a->denum * $fa );
            my $s = VulFrac->new(
                          num => $i ? $a->num * $fa - $b->num * $fb : $a->num * $fa + $b->num * $fb,
                          denum => $a->denum * $fa );
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
