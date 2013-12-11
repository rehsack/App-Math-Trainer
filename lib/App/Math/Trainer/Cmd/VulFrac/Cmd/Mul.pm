package App::Math::Trainer::Cmd::VulFrac::Cmd::Mul;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Cmd::VulFrac::Cmd::Mul - Plugin for multiplication and division of vulgar fraction

=cut

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options;

has template_filename => (
                           is      => "ro",
                           default => "twocols"
                         );

with "App::Math::Trainer::Role::VulFracExercise";

sub _build_command_names
{
    return qw(mul div);
}

sub _euklid
{
    my ( $a, $b ) = @_;
    my $h;
    while ( $b != 0 ) { $h = $a % $b; $a = $b; $b = $h; }
    return $a;
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
            my ( $a, $b ) = @$line[ 2 * $i, 2 * $i + 1 ];
            my $op = $i ? '\div' : '\cdot';
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

            @$a{ 'num', 'denum' } = _reduce( @$a{ 'num', 'denum' } );
            @$b{ 'num', 'denum' } = _reduce( @$b{ 'num', 'denum' } );

            push(
                  @way,
                  sprintf(
                           '\frac{%d}{%d} %s \frac{%d}{%d}',
                           $a->{num}, $a->{denum}, $op, $b->{num}, $b->{denum}
                         )
                );

            my $c = {};
            unless ($i)
            {
                # multiplication
                push(
                      @way,
                      sprintf(
                               '\frac{%d \cdot %d}{%d \cdot %d}',
                               $a->{num}, $b->{num}, $a->{denum}, $b->{denum}
                             )
                    );
                @$c{ 'num', 'denum' } = ( $a->{num} * $b->{num}, $a->{denum} * $b->{denum} );
            }
            else
            {
                #division
                push(
                      @way,
                      sprintf(
                               '\frac{%d \cdot %d}{%d \cdot %d}',
                               $a->{num}, $b->{denum}, $b->{num}, $a->{denum}
                             )
                    );
                @$c{ 'num', 'denum' } = ( $a->{num} * $b->{denum}, $b->{num} * $a->{denum} );
            }
            push( @way, sprintf( '\frac{%d}{%d}', @$c{ 'num', 'denum' } ) );
            my $cc = {};
            @$cc{ 'num', 'denum' } = _reduce( @$c{ 'num', 'denum' } );
            $cc->{num} != $c->{num}
              and $c = $cc
              and push( @way, sprintf( '\frac{%d}{%d}', @$c{ 'num', 'denum' } ) );

            my $n;
            $c->{num} > $c->{denum}
              and push(
                        @way,
                        sprintf(
                                 '\normalsize{%d} \frac{%d}{%d}',
                                 $n = int( $c->{num} / $c->{denum} ),
                                 $c->{num} - $c->{denum} * $n,
                                 $c->{denum}
                               )
                      );

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
