package App::Math::Trainer::Command::FracAdd;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Command::FracAdd - Plugin for addition and subtraction of vulgar fractions

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
             [ "amount|n=i", "specifies amount of calculations to generate" ],
             [ "format|f=s", "specifies format of numerator/denominator" ],
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

    return;
}

=head2 command_names

Delivers the commands supported by this command class.

=cut

sub command_names
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

    foreach my $i ( 1 .. $amount )
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
	section => "Vulgar fraction addition / subtraction",
	caption => 'Fractions',
	label => 'vulgar_fractions_addition',
        header => [ [ 'Vulgar Fraction Addition', 'Vulgar Fraction Subtraction' ] ],
        solutions => [],
        tasks     => [],
                  };

    # use Text::TabularDisplay;
    # my $table = Text::TabularDisplay->new( 'Bruch -> Dez', 'Dez -> Bruch' );
    foreach my $line (@tasks)
    {
        my ( @solution, @task );
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
            push(
                  @way,
                  sprintf(
                           '\frac{%d * %d}{%d * %d} %s \frac{%d * %d}{%d * %d}',
                           $a->{num}, $fa,
                           $a->{denum}, $fa,
                           $op,
                           $b->{num}, $fb,
                           $b->{denum}, $fb
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
            my @c = _cancel( $s, $a->{denum} * $fa );
            $c[0] != $s and push( @way, sprintf( '\frac{%d}{%d}', @c ) );

            push( @solution, '$ ' . join( " = ", @way ) . ' $' );
        }

        push( @{ $problem->{solutions} }, \@solution );
        push( @{ $problem->{tasks} },     \@task );
    }
    # print $table->render(), "\n";

    my $sharedir = File::ShareDir::dist_dir("App-Math-Trainer");
    my $ttcpath = File::Spec->catfile( $sharedir, "twocols.tt2" );

    my $template = Template->new( { ABSOLUTE => 1, } );
    my $rc = $template->process( $ttcpath, { problem => $problem }, "vfadd.pdf" );
    $rc or croak( $template->error() );

    return 0;
}
