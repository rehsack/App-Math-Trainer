package App::Math::Trainer::Cmd::Frac::Cmd::Mul;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Cmd::Frac::Cmd::Mul - Plugin for multiplication and division of vulgar fraction

=cut

our $VERSION = '0.002';

use Moo;
use MooX::Cmd;
use MooX::Options;

use Carp qw(croak);
use File::ShareDir ();
use Template       ();

with "App::Math::Trainer::Role::FracExercise";

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

sub execute
{
    my ( $self, $opt, $args ) = @_;

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

    my $problem = {
                    section => "Vulgar fraction multiplication / division",
                    caption => 'Fractions',
                    label   => 'vulgar_fractions_multiplication',
                    header  => [ [ 'Vulgar Fraction Multiplication', 'Vulgar Fraction Division' ] ],
                    solutions => [],
                    tasks     => [],
                  };

    foreach my $line (@tasks)
    {
        my ( @solution, @task );

        foreach my $i ( 0 .. 1 )
        {
            my ( $a, $b ) = @$line[ 2 * $i, 2 * $i + 1 ];
            my $op = $i ? '\div' : '\cdot';
            push(
                  @task,
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
            push( @way, sprintf( '\frac{%d}{%d}', $c->{num}, $c->{denum} ) );
            my $cc = {};
            @$cc{ 'num', 'denum' } = _reduce( $c->{num}, $c->{denum} );
            $cc->{num} != $c->{num}
              and push( @way, sprintf( '\frac{%d}{%d}', $cc->{num}, $cc->{denum} ) );

            push( @solution, '$ ' . join( " = ", @way ) . ' $' );
        }

        push( @{ $problem->{solutions} }, \@solution );
        push( @{ $problem->{tasks} },     \@task );
    }

    my $sharedir = File::ShareDir::dist_dir("App-Math-Trainer");
    my $ttcpath = File::Spec->catfile( $sharedir, "twocols.tt2" );

    my $template = Template->new(
                                  {
                                    ABSOLUTE => 1,
                                  }
                                );
    my $rc = $template->process(
                                 $ttcpath,
                                 {
                                    problem => $problem,
                                    output  => {
                                                format => 'pdf',
                                              },
                                 },
                                 "vfmul.pdf"
                               );
    $rc or croak( $template->error() );

    return 0;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2013 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
