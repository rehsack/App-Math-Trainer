package App::Math::Trainer::Command::FracMul;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Command::FracMul - Plugin for multiplication and division of vulgar fraction

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
    return ( [ "amount|n=i", "specifies amount of calculations to generate" ],
             [ "format|f=s", "specifies format of numerator/denominator" ], );
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
    return qw(mul div);
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
            my $op = $i ? ':' : '*';
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
                               '\frac{%d * %d}{%d * %d}',
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
                               '\frac{%d * %d}{%d * %d}',
                               $a->{num}, $b->{denum}, $b->{num}, $a->{denum}
                             )
                    );
                @$c{ 'num', 'denum' } = ( $a->{num} * $b->{denum}, $b->{num} * $a->{denum} );
            }
            push( @way, sprintf( '\frac{%d}{%d}', $c->{num}, $c->{denum} ) );
            my $cc = {};
            @$cc{ 'num', 'denum' } = _cancel( $c->{num}, $c->{denum} );
            $cc->{num} != $c->{num}
              and push( @way, sprintf( '\frac{%d}{%d}', $cc->{num}, $cc->{denum} ) );

            push( @solution, '$ ' . join( " = ", @way ) . ' $' );
        }

        push( @{ $problem->{solutions} }, \@solution );
        push( @{ $problem->{tasks} },     \@task );
    }

    my $sharedir = File::ShareDir::dist_dir("App-Math-Trainer");
    my $ttcpath = File::Spec->catfile( $sharedir, "twocols.tt2" );

    my $template = Template->new( { ABSOLUTE => 1, } );
    my $rc = $template->process( $ttcpath, { problem => $problem }, "vfmul.pdf" );
    $rc or croak( $template->error() );

    return 0;
}

1;
