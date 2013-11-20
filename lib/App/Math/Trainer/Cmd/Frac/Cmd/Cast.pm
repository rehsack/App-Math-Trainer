package App::Math::Trainer::Cmd::Frac::Cmd::Cast;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Command::FracCast - Plugin for casting of vulgar fraction into decimal fraction and vice versa

=head1 SYNOPSIS

=cut

our $VERSION = '0.001';

use Moo;
use MooX::Cmd;
use MooX::Options;

use Carp qw(croak);
use File::ShareDir ();
use Template       ();
use Scalar::Util qw(looks_like_number);

with "App::Math::Trainer::Role::FracExercise";

sub _lt { return $_[0] < $_[1]; }
sub _le { return $_[0] <= $_[1]; }
sub _gt { return $_[0] > $_[1]; }
sub _ge { return $_[0] >= $_[1]; }
sub _ok { return 1; }

option range => (
    is  => "ro",
    doc => "specifies range of resulting numbers ([m..n] or [m..[n or m]..n] ...)",
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
		        )?$/x);
        my ($minr, $minc, $maxr, $maxc);

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

option digits => (
    is  => "ro",
    doc => "specified number of decimal digits (after decimal point)",
    isa => sub {
    defined( $_[0] )
      and looks_like_number($_[0])
      and $_[0] != int( $_[0] )
      and die("Digits must be natural");
    defined( $_[0] )
      and ( $_[0] < 2 or $_[0] > 13 )
      and die("Digits must be between 2 and 13");
    },
    coerce => sub {
	int($_[0])
    },
    default => sub { return 5; },
    format  => "s",
    short   => "g",
                 );

=head2 command_names

Delivers the commands supported by this command class.

=cut

sub command_names
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

=head2 execute

executes command

=cut

sub execute
{
    my ( $self, $opt, $args ) = @_;

    my (@tasks);
    my ( $maxa, $maxb ) = @{ $self->format };
    my ($minr, $minc, $maxr, $maxc) = @{ $self->range };

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
          } while ( !$minc->( $minr, $a / $b ) || !$maxc->( $maxr, $a / $b ) || $s1 != $a / $b || length($s1) < 3 ); 

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

    my $problem = {
	section => "Vulgar fraction <-> decimal fracion casting",
	caption => 'Fractions',
	label => 'vulgar_decimal_fractions',
        header => [ [ 'Vulgar => Decimal Fraction', 'Decimal => Vulgar Fraction' ] ],
        solutions => [],
        tasks     => [],
                  };

    foreach my $line (@tasks)
    {
        my ( @solution, @task );
        if ( $line->[0][0] == $line->[0][2] )
        {
            push( @solution,
                 sprintf( '$ \frac{%d}{%d} = %s $', $line->[0][0], $line->[0][1], $line->[0][4] ),
                 sprintf( '$ %s = \frac{%d}{%d} $', $line->[1][2], $line->[1][0], $line->[1][1] ) );
            push( @task,
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
            push( @task,
                  sprintf( '$ \frac{%d}{%d} = $', $line->[0][0], $line->[0][1] ),
                  sprintf( '$ %s = $',            $line->[1][2] ) );
        }
        push( @{ $problem->{solutions} }, \@solution );
        push( @{ $problem->{tasks} },     \@task );
    }

    my $sharedir = File::ShareDir::dist_dir("App-Math-Trainer");
    my $ttcpath = File::Spec->catfile( $sharedir, "twocols.tt2" );

    my $template = Template->new( { ABSOLUTE => 1, } );
    my $rc = $template->process( $ttcpath, { problem => $problem, output => { format => 'pdf', }, }, "vfcast.pdf" );
    $rc or croak( $template->error() );

    return 0;
}

1;
