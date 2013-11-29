package App::Math::Trainer::Cmd::Frac::Cmd::Add;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Cmd::Frac::Cmd::Add - Plugin for addition and subtraction of vulgar fractions

=cut

our $VERSION = '0.002';

use Moo;
use MooX::Cmd;
use MooX::Options;

has template_filename => (
                           is      => "ro",
                           default => "twocols"
                         );

with "App::Math::Trainer::Role::FracExercise";

sub _build_command_names
{
    return qw(add sub);
}

sub _euklid
{
    my ( $a, $b ) = @_;
    my $h;
    while ( $b != 0 ) { $h = $a % $b; $a = $b; $b = $h; }
    return $a;
}

sub _gcd
{
    my ( $a, $b ) = @_;
    my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
    return $gcd;
}

sub _reduce
{
    my ( $a, $b ) = @_;
    my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
    $a /= $gcd;
    $b /= $gcd;
    return ( $a, $b );
}

sub _build_exercises
{
    my ($self) = @_;

    my (@tasks);
    my ( $maxa, $maxb ) = @{ $self->format };

    foreach my $i ( 1 .. $self->amount )
    {
        my @numbers;

        foreach my $i ( 0 .. 3 )
        {
            my ( $a, $b );
            do
            {
                ( $a, $b ) = ( int( rand($maxa) ), int( rand($maxb) ) );
            } while ( $a < 2 || $b < 2 );

            $numbers[$i] = {
                             num   => $a,
                             denum => $b
                           };
        }

        push( @tasks, \@numbers );
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
        if ( ( $line->[2]->{num} / $line->[2]->{denum} ) <
             ( $line->[3]->{num} / $line->[3]->{denum} ) )
        {
            # swap
            my $tmp = $line->[2];
            $line->[2] = $line->[3];
            $line->[3] = $tmp;
        }

        foreach my $i ( 0 .. 1 )
        {
            my ( $a, $b ) = @$line[ 2 * $i, 2 * $i + 1 ];
            my $gcd = _gcd( $a->{denum}, $b->{denum} );
            my ( $fa, $fb ) = ( $b->{denum} / $gcd, $a->{denum} / $gcd );
            my $op = $i ? '-' : '+';
            push(
                  @challenge,
                  sprintf(
                           '$ \frac{%d}{%d} %s \frac{%d}{%d} = $',
                           $a->{num}, $a->{denum}, $op, $b->{num}, $b->{denum}
                         )
                );

            my @way;    # remember Frank Sinatra :)
            push(
                  @way,
                  sprintf(
                           '\frac{%d}{%d} %s \frac{%d}{%d}',
                           $a->{num}, $a->{denum}, $op, $b->{num}, $b->{denum}
                         )
                );
            push(
                  @way,
                  sprintf(
                           '\frac{%d \cdot %d}{%d \cdot %d} %s \frac{%d \cdot %d}{%d \cdot %d}',
                           $a->{num}, $fa, $a->{denum}, $fa, $op,
                           $b->{num}, $fb, $b->{denum}, $fb
                         )
                );
            push(
                  @way,
                  sprintf(
                           '\frac{%d}{%d} %s \frac{%d}{%d}',
                           $a->{num} * $fa,
                           $a->{denum} * $fa,
                           $op,
                           $b->{num} * $fb,
                           $b->{denum} * $fb
                         )
                );
            push(
                  @way,
                  sprintf(
                           '\frac{%d %s %d}{%d}',
                           $a->{num} * $fa,
                           $op,
                           $b->{num} * $fb,
                           $a->{denum} * $fa
                         )
                );
            my $s = $i ? $a->{num} * $fa - $b->{num} * $fb : $a->{num} * $fa + $b->{num} * $fb;
            push( @way, sprintf( '\frac{%d}{%d}', $s, $a->{denum} * $fa ) );
            my @c = _reduce( $s, $a->{denum} * $fa );
            $c[0] != $s and push( @way, sprintf( '\frac{%d}{%d}', @c ) );

            push( @solution, '$ ' . join( " = ", @way ) . ' $' );
        }

        push( @{ $exercises->{solutions} },  \@solution );
        push( @{ $exercises->{challenges} }, \@challenge );
    }

    return $exercises;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2013 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
