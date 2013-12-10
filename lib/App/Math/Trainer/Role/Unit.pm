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
    package    #
      Unit;

    use Moo;
    use overload
      '""'   => \&_stringify,
      '0+'   => \&_numify,
      'bool' => \&_filled,
      '<=>'  => \&_num_compare;

    has type => (
                  is       => "ro",
                  required => 1
                );
    has begin => (
                   is       => "ro",
                   required => 1
                 );
    has end => (
                 is       => "ro",
                 required => 1
               );
    has parts => (
                   is        => "ro",
                   rerquired => 1
                 );

    sub _stringify
    {
        my @parts = @{ $_[0]->parts };
        my @res;
        for my $i ( $_[0]->begin .. $_[0]->end )
        {
            my $num = shift @parts;
            $num or next;
            my $un = $_[0]->type->{spectrum}->[$i]->{unit};
            $un = "\\text{$un }";
            push( @res, "$num $un" );
        }
        join( " ", @res );
        #join(" ", @{ $_[0]->parts } );
    }

    sub _numify
    {
        my @parts = @{ $_[0]->parts };
        my $res   = 0;
        for my $i ( $_[0]->begin .. $_[0]->end )
        {
            my $num = shift @parts;
            $num or next;
            my $factor = $_[0]->type->{spectrum}->[$i]->{factor};
            $res = $i <= $_[0]->type->{base} ? $res + $num * $factor : $res + $num / $factor;
        }

        $res;
    }

    sub _filled
    {
        grep { $_ } @{ $_[0]->parts };
    }

    sub _num_compare
    {
        my ( $self, $other, $swapped ) = @_;
        $swapped and return $other <=> $self->_numify;

        my $rc;
        0 != ( $rc = $other->begin <=> $self->begin )
          and return $rc;    # $self->begin < $other->begin => $self > $other
        return $self->_numify <=> $other->_numify;
    }
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
                       divider => {
                                    'cent' => {
                                                factor => 100,
                                                max    => 99
                                              }
                                  },
                     },
             pound => {
                        base    => { '\textsterling{}' => {} },
                        divider => {
                                     'p' => {
                                              factor => 100,
                                              max    => 99
                                            }
                                   },
                      },
             dollar => {
                         base    => { '\textdollar{}' => {} },
                         divider => {
                                      '\textcent{}' => {
                                                         factor => 100,
                                                         max    => 99
                                                       }
                                    },
                       },
           };
}

sub _lt { return $_[0] < $_[1]; }
sub _le { return $_[0] <= $_[1]; }
sub _gt { return $_[0] > $_[1]; }
sub _ge { return $_[0] >= $_[1]; }
sub _ok { return 1; }

has ordered_units => ( is => "lazy" );

requires "relevant_units";

sub _build_ordered_units_flatten_helper
{
    my $unit_part = $_[0];
    my @flatten;

    foreach my $upnm ( keys %{$unit_part} )
    {
        my ( $min, $max, $factor ) = @{ $unit_part->{$upnm} }{qw(min max factor)};
        defined $min    or $min    = 0;
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
    my $ru = $self->relevant_units;

    foreach my $cat (@$ru)
    {
        my @base = _build_ordered_units_flatten_helper( $ud->{$cat}->{base} );
        my @mult = _build_ordered_units_flatten_helper( $ud->{$cat}->{multiplier} );
        my @div  = _build_ordered_units_flatten_helper( $ud->{$cat}->{divider} );
        my %ru;    # reworked unit

        1 != scalar @base and die "Invalid unit description: $cat";

        @mult = sort { $b->{factor} <=> $a->{factor} } @mult;
        @div  = sort { $a->{factor} <=> $b->{factor} } @div;
        $ru{base}     = scalar @mult;
        $ru{spectrum} = [ @mult, @base, @div ];
        $ou{$cat}     = \%ru;
    }

    return \%ou;
}

sub _guess_unit_number
{
    my ( $unit_type, $lb, $ub ) = @_;
    my @rc;

    $lb == $ub and $lb == scalar @{ $unit_type->{spectrum} } and --$lb;
    $lb == $ub and $ub == 0 and scalar @{ $unit_type->{spectrum} } > 0 and ++$ub;
    $lb == $ub and $ub < $unit_type->{base} and ++$ub;
    $lb == $ub and --$lb;

  REDO:
    my $i;
    for ( $i = $lb; $i <= $ub; ++$i )
    {
        my $max =
          defined $unit_type->{spectrum}->[$i]->{max} ? $unit_type->{spectrum}->[$i]->{max} : 100;
        my $min   = $unit_type->{spectrum}->[$i]->{min};
        my $value = int( rand( $max + $min ) ) - $min;
        $value or @rc or ++$lb;
        $value or @rc or next;
        push( @rc, $value );
    }
    while ( !$rc[-1] )
    {
        pop @rc;
        --$ub;
    }
    @rc or goto REDO;

    return
      Unit->new(
                 type  => $unit_type,
                 begin => $lb,
                 end   => $ub,
                 parts => \@rc
               );
}

requires "unit_length";
requires "deviation";

sub get_unit_numbers
{
    my ( $self, $amount ) = @_;

    my $ou = $self->ordered_units;
    my @result;
    my @unames    = keys %$ou;
    my $nunits    = scalar @unames;
    my $_ut       = int( rand($nunits) );
    my $ut        = $ou->{ $unames[$_ut] };
    my $length    = $self->has_unit_length ? $self->unit_length : scalar @{ $ut->{spectrum} };
    my $deviation = $self->deviation;
    my ( $lo, $uo );

    my $fits = sub {
        my ( $lb, $ub ) = @_;
        $ub - $lb >= $length and return 0;
        defined $deviation or return 1;
        defined $lo and abs( $lb - $lo ) > $deviation and return 0;
        defined $uo and abs( $lb - $uo ) > $deviation and return 0;
        return 1;
    };

    while ( $amount-- )
    {
        my ( @bounds, $unit );
        do
        {
            @bounds = (
                        int( rand( scalar @{ $ut->{spectrum} } ) ),
                        int( rand( scalar @{ $ut->{spectrum} } ) )
                      );
            $bounds[0] > $bounds[1] and @bounds = reverse @bounds;
        } while ( !$fits->(@bounds) );

        $unit = _guess_unit_number( $ut, @bounds );
        @result or ( $lo, $uo ) = ( $unit->begin, $unit->end );
        push( @result, $unit );
    }

    return @result;
}

1;
