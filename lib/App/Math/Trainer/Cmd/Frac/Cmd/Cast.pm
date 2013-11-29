package App::Math::Trainer::Cmd::Frac::Cmd::Cast;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Cmd::Frac::Cmd::Cast - Plugin for casting of vulgar fraction into decimal fraction and vice versa

=cut

our $VERSION = '0.002';

use Moo;
use MooX::Cmd;
use MooX::Options;

use Carp qw(croak);
use File::ShareDir ();
use Template       ();
use Scalar::Util qw(looks_like_number);

has template_filename => (
                           is      => "ro",
                           default => "twocols"
                         );

with "App::Math::Trainer::Role::FracExercise";

sub _lt { return $_[0] < $_[1]; }
sub _le { return $_[0] <= $_[1]; }
sub _gt { return $_[0] > $_[1]; }
sub _ge { return $_[0] >= $_[1]; }
sub _ok { return 1; }

=head1 ATTRIBUTES

=head2 range

Specifies range of resulting numbers ([m..n] or [m..[n or m]..n] ...)

=cut

option range => (
    is       => "ro",
    doc      => "Specifies range of results",
    long_doc => "Specifies range of fraction value using a lower and an upper limit:\n\n"
      . "\t--range [m..n] -- includes value of m and n in range\n\n"
      . "\t--range [m..[n -- includes value of m in range, but exlude n\n\n"
      . "\t--range m]..n] -- excludes value of m from rangem but include n\n\n",
    isa => sub {
        defined( $_[0] )
          and !ref $_[0]
          and $_[0] !~ m/^(\[?)((?:\d?\.)?\d+)(\]?)\.\.(\[?)((?:\d?\.)?\d+)(\]?)$/
          and die("Invalid range");
    },
    coerce => sub {
        defined( $_[0] )
          or return [ 0, \&_lt, undef, \&_ok ];

        ref $_[0] eq "ARRAY" and return $_[0];

        my ( $fmtmin, $fmtmax ) = (
            $_[0] =~ m/^( (?:\[(?:\d+\.?\d*)|(?:\.?\d+))
			  |
			  (?:(?:\d+\.?\d*)|(?:\.?\d+)\])
		        )
		        (?:\.\.
			  (
			      (?:\[(?:\d+\.?\d*)|(?:\.?\d+))
			      |
			      (?:(?:\d+\.?\d*)|(?:\.?\d+)\])
			  )
		        )?$/x
                                  );
        my ( $minr, $minc, $maxr, $maxc );

        $fmtmin =~ s/^\[// and $minc = \&_le;
        $fmtmin =~ s/\]$// and $minc = \&_lt;
        defined $minc or $minc = \&_lt;
        $minr = $fmtmin;

        if ( defined($fmtmax) )
        {
            $fmtmax =~ s/^\[// and $maxc = \&_gt;
            $fmtmax =~ s/\]$// and $maxc = \&_ge;
            defined $maxc or $maxc = \&_ge;
            $maxr = $fmtmax;
        }
        else
        {
            $maxc = \&_ok;
        }

        return [ $minr, $minc, $maxr, $maxc ];
    },
    default => sub { return [ 0, \&_lt, undef, \&_ok ]; },
    format  => "s",
    short   => "r",
                );

=head2 digits

Specifies number of decimal digits (after decimal point)

=cut

option digits => (
    is       => "ro",
    doc      => "Specified number of decimal digits (after decimal point)",
    long_doc => "Specify count of decimal digits after decimal point (limit value using range)",
    isa      => sub {
        defined( $_[0] )
          and looks_like_number( $_[0] )
          and $_[0] != int( $_[0] )
          and die("Digits must be natural");
        defined( $_[0] )
          and ( $_[0] < 2 or $_[0] > 13 )
          and die("Digits must be between 2 and 13");
    },
    coerce => sub {
        int( $_[0] );
    },
    default => sub { return 5; },
    format  => "s",
    short   => "g",
                 );

sub _build_command_names
{
    return qw(cast);
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
    my ( $minr, $minc, $maxr, $maxc ) = @{ $self->range };

    my $digits = $self->digits;

    foreach my $i ( 1 .. $self->amount )
    {
        my ( @line, $a, $b, $ca, $cb, $s1, $c, $d, $s2 );
      NEXT_A:
        do
        {
            ( $a, $b ) = ( int( rand($maxa) ), int( rand($maxb) ) );
            ( $ca, $cb ) = _reduce( $a, $b );
            $ca < 2 and goto NEXT_A;
            $cb < 2 and goto NEXT_A;
            $s1 = sprintf( "%0.${digits}g", $a / $b );
          } while (    !$minc->( $minr, $a / $b )
                    || !$maxc->( $maxr, $a / $b )
                    || $s1 != $a / $b
                    || length($s1) < 3 );

      NEXT_B:
        do
        {
            ( $c, $d ) = ( int( rand($maxa) ), int( rand($maxb) ) );
            ( $c, $d ) = _reduce( $c, $d );
            $c < 2 and goto NEXT_B;
            $d < 2 and goto NEXT_B;
            $s2 = sprintf( "%0.${digits}g", $c / $d );
          } while ( !&{$minc}( $minr, $c / $d )
                      || !&{$maxc}( $maxr, $c / $d )
                      || $s2 != $c / $d
                    || length($s2) < 3 );

        $line[0] = [ $a, $b, $ca, $cb, $s1 ];
        $line[1] = [ $c, $d, $s2 ];

        push( @tasks, \@line );
    }

    my $exercises = {
                      section => "Vulgar fraction <-> decimal fracion casting",
                      caption => 'Fractions',
                      label   => 'vulgar_decimal_fractions',
                      header  => [ [ 'Vulgar => Decimal Fraction', 'Decimal => Vulgar Fraction' ] ],
                      solutions => [],
                      challenges     => [],
                    };

    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );
        if ( $line->[0][0] == $line->[0][2] )
        {
            push( @solution,
                 sprintf( '$ \frac{%d}{%d} = %s $', $line->[0][0], $line->[0][1], $line->[0][4] ),
                 sprintf( '$ %s = \frac{%d}{%d} $', $line->[1][2], $line->[1][0], $line->[1][1] ) );
            push( @challenge,
                  sprintf( '$ \frac{%d}{%d} = $', $line->[0][0], $line->[0][1] ),
                  sprintf( '$ %s = $',            $line->[1][2] ) );
        }
        else
        {
            push(
                  @solution,
                  sprintf(
                           '$ \frac{%d}{%d} = \frac{%d}{%d} = %s $',
                           $line->[0][0], $line->[0][1], $line->[0][2],
                           $line->[0][3], $line->[0][4]
                         ),
                  sprintf( '$ %s = \frac{%d}{%d} $', $line->[1][2], $line->[1][0], $line->[1][1] )
                );
            push( @challenge,
                  sprintf( '$ \frac{%d}{%d} = $', $line->[0][0], $line->[0][1] ),
                  sprintf( '$ %s = $',            $line->[1][2] ) );
        }
        push( @{ $exercises->{solutions} }, \@solution );
        push( @{ $exercises->{challenges} },     \@challenge );
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
