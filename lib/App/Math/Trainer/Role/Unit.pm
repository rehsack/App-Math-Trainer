package App::Math::Trainer::Role::Unit;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer::Role::Unit - role for numererical parts for calculation with units

=cut

use Moo::Role;
use MooX::Options;

our $VERSION = '0.003';

use Hash::MoreUtils qw/slice_def/;
use List::MoreUtils qw/firstidx/;

{
    package #
	Unit;

    use Moo;
}

has unit_definitions => ( is => "lazy" );

sub _build_unit_definitions
{
    return {
             time => {
                       base       => { s => { max => 59 } },
                       multiplier => {
                                       w => {
                                              max    => 52,
                                              factor => 7 * 24 * 60 * 60,
                                            },
                                       d => {
                                              max    => 6,
                                              factor => 24 * 60 * 60,
                                            },
                                       h => {
                                              max    => 23,
                                              factor => 60 * 60,
                                            },
                                       min => {
                                                max    => 59,
                                                factor => 60,
                                              },
                                     },
                       divider => {
                                    ms => {
                                            max    => 999,
                                            factor => 1000,
                                          },
                                  },
                     },
             length => {
                         base       => { m => { max => 999 } },
                         multiplier => {
                                         km => {
                                                 factor => 1000,
                                               },
                                       },
                         divider => {
                                      dm => {
                                              max    => 9,
                                              factor => 10,
                                            },
                                      cm => {
                                              max    => 9,
                                              factor => 100,
                                            },
                                      mm => {
                                              max    => 9,
                                              factor => 1000,
                                            },
                                    }
                       },
             weight => {
                         base       => { g => { max => 999 } },
                         multiplier => {
                                         kg => {
                                                 max    => 1000,
                                                 factor => 1000,
                                               },
                                         t => {
                                                factor => 1000 * 1000,
                                              },
                                       },
                         divider => {
                                      mg => {
                                              max    => 999,
                                              factor => 1000,
                                            },
                                    },
                       },
             euro => {
                       base    => { '\euro{}' => {} },
                       divider => { 'ct'      => { factor => 100 } },
                     },
             pound => {
                        base    => { '\textsterling{}' => {} },
                        divider => { 'ct'              => { factor => 100 } },
                      },
             dollar => {
                         base    => { '\textdollar{}' => {} },
                         divider => { 'ct'            => { factor => 100 } },
                       },
           };
}

sub _lt { return $_[0] < $_[1]; }
sub _le { return $_[0] <= $_[1]; }
sub _gt { return $_[0] > $_[1]; }
sub _ge { return $_[0] >= $_[1]; }
sub _ok { return 1; }

has ordered_units => ( is => "lazy" );

sub _build_ordered_units_flatten_helper
{
    my $unit_part = $_[0];
    my @flatten;

    foreach my $upnm ( keys %{$unit_part} )
    {
	my ( $min, $max, $factor ) = @{ $unit_part->{$upnm} }{qw(min max factor)};
	defined $min or $min = 0;
	defined $factor or $factor = 1;
	my %upv = slice_def {
			      min    => $min,
			      max    => $max,
			      factor => $factor,
			      unit   => $upnm
			    };
	my @match;
	$min and push( @match, "_le($min,\$_[0])" );
	$max and push( @match, "_ge($max,\$_[0])" );
	@match or @match = ("1");
	$upv{match} = eval sprintf( "sub { %s };", join( " and ", @match ) );
	push @flatten, \%upv;
    }

    @flatten;
}

sub _build_ordered_units
{
    my $self = shift;
    my %ou;    # ordered units
    my $ud = $self->unit_definitions;

    foreach my $cat ( keys %$ud )
    {
        my @base = _build_ordered_units_flatten_helper($ud->{$cat}->{base});
        my @mult = _build_ordered_units_flatten_helper($ud->{$cat}->{multiplier});
        my @div = _build_ordered_units_flatten_helper($ud->{$cat}->{divider});
        my %ru;    # reworked unit

	1 != scalar @base and die "Invalid unit description: $cat";

        @mult = sort { $b->{factor} <=> $a->{factor} } @mult;
        @div  = sort { $a->{factor} <=> $b->{factor} } @div;
        $ru{base} = scalar @mult;
        $ru{spectrum} = [ @mult, @base, @div ];
        $ou{$cat} = \%ru;
    }

    return \%ou;
}

sub _guess_unit_number
{
    my ( $unit_type, $lb, $ub ) = @_;
    my @rc;

    $lb == $ub and $lb ==  scalar @{$unit_type->{spectrum}} and --$lb;
    $lb == $ub and $ub == 0 and scalar @{$unit_type->{spectrum}} > 0 and ++$ub;
    $lb == $ub and $ub < $unit_type->{base} and ++$ub;
    $lb == $ub and --$lb;

    my $i;
    for($i = $lb; $i <= $ub; ++$i)
    {
	my $max = defined $unit_type->{spectrum}->[$i]->{max} ? $unit_type->{spectrum}->[$i]->{max} : 100;
	my $min = $unit_type->{spectrum}->[$i]->{min};
	my $value = int(rand($max+$min)) - $min;
	push(@rc, $value, $unit_type->{spectrum}->[$i]->{unit});
    }

    return Unit->new(type => $unit_type, parts => \@rc);
}

sub get_unit_numbers
{
    my ( $self, $amount ) = @_;

    my $ou = $self->ordered_units;
    my @result;
    my @unames = keys %$ou;
    my $nunits = scalar @unames;

    while ( $amount-- )
    {
        my $_ut    = int( rand($nunits) );
        my $ut     = $ou->{ $unames[$_ut] };
        my @bounds = ( int( rand( scalar @{ $ut->{spectrum} } ) ),
                       int( rand( scalar @{ $ut->{spectrum} } ) ) );
        my $unit =
          $bounds[0] <= $bounds[1]
          ? _guess_unit_number( $ut, @bounds )
          : _guess_unit_number( $ut, $bounds[1], $bounds[0] );
	push(@result, $unit);
    }

    return @result;
}

1;
