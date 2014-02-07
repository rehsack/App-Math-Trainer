package App::Math::Tutor::Cmd::VulFrac::Cmd::Add;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Tutor::Cmd::VulFrac::Cmd::Add - Plugin for addition and subtraction of vulgar fractions

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
    return qw(add sub);
}

sub _build_exercises
{
    my ($self) = @_;
    my $neg = $self->negativable;

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
                      section => "Vulgar fraction addition / subtraction",
                      caption => 'Fractions',
                      label   => 'vulgar_fractions_addition',
                      header  => [ [ 'Vulgar Fraction Addition', 'Vulgar Fraction Subtraction' ] ],
                      solutions  => [],
                      challenges => [],
                    };
    my $a_plus_b = sub {
        return
          PolyNum->new( operator => $_[0],
                        values   => [ splice @_, 1 ] );
    };
    my $a_mult_b = sub {
        return
          ProdNum->new( operator => $_[0],
                        values   => [ splice @_, 1 ] );
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
            $op eq '-' and $a < $b and ( $b, $a ) = ( $a, $b ) unless $neg;
            push @challenge, sprintf( '$ %s = $', $a_plus_b->( $op, $a, $b ) );

            my @way;    # remember Frank Sinatra :)
            push @way, $a_plus_b->( $op, $a, $b );

            ( $a, $b ) = ( $a->_reduce, $b = $b->_reduce ) and push @way, $a_plus_b->( $op, $a, $b )
              if ( $a->_gcd > 1 or $b->_gcd > 1 );

            my $gcd = VulFracNum->new(
                                       num   => $a->denum,
                                       denum => $b->denum
                                     )->_gcd;
            my ( $fa, $fb ) = ( $b->{denum} / $gcd, $a->{denum} / $gcd );

            my ( $xa, $xb ) = (
                                VulFracNum->new(
                                                 num   => $a_mult_b->( '*', $a->num,   $fa ),
                                                 denum => $a_mult_b->( '*', $a->denum, $fa ),
                                                 sign  => $a->sign
                                               ),
                                VulFracNum->new(
                                                 num   => $a_mult_b->( '*', $b->num,   $fb ),
                                                 denum => $a_mult_b->( '*', $b->denum, $fb ),
                                                 sign  => $b->sign
                                               )
                              );
            push @way, $a_plus_b->( $op, $xa, $xb );
            $xa = VulFracNum->new(
                                   num   => int( $xa->num ),
                                   denum => int( $xa->denum ),
                                   sign  => $xa->sign
                                 );
            $xb = VulFracNum->new(
                                   num   => int( $xb->num ),
                                   denum => int( $xb->denum ),
                                   sign  => $xb->sign
                                 );
            push @way, $a_plus_b->( $op, $xa, $xb );

            my $s = VulFracNum->new(
                            num   => $a_plus_b->( $op, $xa->sign * $xa->num, $xb->sign * $xb->num ),
                            denum => $xa->denum );

            push @way, $s;
            $s = VulFracNum->new(
                                  num   => int( $s->num ),
                                  denum => $s->denum,
                                  sign  => $s->sign
                                );
            push @way, "" . $s;
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
