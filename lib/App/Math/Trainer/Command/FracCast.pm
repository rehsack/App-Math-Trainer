package App::Math::Trainer::Command::FracCast;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Command::FracCast - Plugin for casting of vulgar fraction into decimal fraction and vice versa

=head1 SYNOPSIS

=cut

our $VERSION = '0.001';

use App::Math::Trainer -command;

use Carp qw(croak);
use File::ShareDir ();
use Template       ();

=head2 opt_spec

Delivers the options supported by this command class.

=cut

sub opt_spec
{
    return (
             [ "amount|n=i", "specifies amount of calculations to generate (default: 25)" ],
             [ "format|f=s", "specifies format of numerator/denominator (-f nn:nnn)" ],
             [
                "range|r=s", "specifies range of resulting numbers ([m..n] or [m..[n or m]..n] ...)"
             ],
             [ "digits|g=i", "specified number of decimal digits (after decimal point)" ],
           );
}

=head2 validate_args

Validates the arguments given by user.

=cut

sub validate_args
{
    my ( $self, $opt, $args ) = @_;

    defined( $opt->{format} )
      and $opt->{format} !~ m/^\d?n+(?::\d?n+)?$/
      and $self->usage_error("Invalid format");
    defined( $opt->{range} )
      and $opt->{range} !~ m/^(\[?)((?:\d?\.)?\d+)(\]?)\.\.(\[?)((?:\d?\.)?\d+)(\]?)$/
      and $self->usage_error("Invalid range");
    defined( $opt->{digits} )
      and $opt->{digits} != int( $opt->{digits} )
      and $self->usage_error("Digits must be natural");
    defined( $opt->{digits} )
      and ( $opt->{digits} < 2 or $opt->{digits} > 13 )
      and $self->usage_error("Digits must be between 2 and 13");

    return;
}

=head2 command_names

Delivers the commands supported by this command class.

=cut

sub command_names
{
    return qw(cast);
}

sub _lt { return $_[0] < $_[1]; }
sub _le { return $_[0] <= $_[1]; }
sub _gt { return $_[0] > $_[1]; }
sub _ge { return $_[0] >= $_[1]; }
sub _ok { return 1; }

sub _euklid
{
    my ( $a, $b ) = @_;
    my $h;
    while ( $b != 0 ) { $h = $a % $b; $a = $b; $b = $h; }
    return $a;
}

sub _cancel
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

    my ( @tasks, $maxa, $maxb, $minr, $maxr, $minc, $maxc );
    my $amount = defined( $opt->{amount} ) ? $opt->{amount} : 25;
    if ( defined( $opt->{format} ) )
    {
        my ( $fmta, $fmtb ) = ( $opt->{format} =~ m/^(\d?n+)(?::(\d?n+))?$/ );
        defined $fmtb or $fmtb = $fmta;
	my $starta = "1";
	my $startb = "1";
	$fmta =~ s/^(\d)(.*)/$2/ and $starta = $1;
	$fmtb =~ s/^(\d)(.*)/$2/ and $startb = $1;
        $maxa = $starta . "0" x length($fmta);
        $maxb = $startb . "0" x length($fmtb);
    }
    else
    {
        $maxa = $maxb = 100;
    }

    if ( defined( $opt->{range} ) )
    {
        my ( $fmtmin, $fmtmax ) = (
            $opt->{range} =~ m/^(
						    	  (?:\[(?:\d+\.?\d*)|(?:\.?\d+))
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
        if ( $fmtmin =~ s/^\[// )
        {
            $minc = \&_le;
        }
        elsif ( $fmtmin =~ s/\]$// )
        {
            $minc = \&_lt;
        }
        else
        {
            # default
            $minc = \&_lt;
        }
        $minr = $fmtmin;

        if ( defined($fmtmax) )
        {
            if ( $fmtmax =~ s/^\[// )
            {
                $maxc = \&_gt;
            }
            elsif ( $fmtmax =~ s/\]$// )
            {
                $maxc = \&_ge;
            }
            else
            {
                # default
                $maxc = \&_ge;
            }
            $maxr = $fmtmax;
        }
        else
        {
            $maxc = \&_ok;
        }
    }
    else
    {
        $minr = 0;
        $minc = \&_lt;
        $maxr = 10;
        $maxc = \&_ge;
    }

    my $digits = 5;
    defined( $opt->{digits} ) and $digits = $opt->{digits};

    foreach my $i ( 1 .. $amount )
    {
        my ( @line, $a, $b, $ca, $cb, $s1, $c, $d, $s2 );
      NEXT_A:
        do
        {
            ( $a, $b ) = ( int( rand($maxa) ), int( rand($maxb) ) );
            ( $ca, $cb ) = _cancel( $a, $b );
            $a < 2 and goto NEXT_A;
            $b < 2 and goto NEXT_A;
            $s1 = sprintf( "%0.${digits}g", $a / $b );
          } while ( !&{$minc}( $minr, $a / $b )
                      || !&{$maxc}( $maxr, $a / $b )
                      || $s1 != $a / $b
                    || length($s1) < 3 );

      NEXT_B:
        do
        {
            ( $c, $d ) = ( int( rand($maxa) ), int( rand($maxb) ) );
            ( $c, $d ) = _cancel( $c, $d );
            $c < 2 and goto NEXT_B;
            $c < 2 and goto NEXT_B;
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
