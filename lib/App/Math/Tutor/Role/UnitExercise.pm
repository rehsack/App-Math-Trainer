package App::Math::Tutor::Role::UnitExercise;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::FracExercise - role for exercises in calculation with units

=cut

use Moo::Role;
use MooX::Options;

option "relevant_units" => (
                  is       => "lazy",
                  doc      => "Specifies the units relevant for the exercise",
                  long_doc => "Specifies the units relevant for the exercise using one or more of: "
                    . "time, length, weight, euro, pound, dollar.",
                  coerce     => \&_coerce_relevant_units,
                  format     => "s@",
                  autosplit  => ",",
                  repeatable => 1,
                  short      => "r",
);

my $single_inst;
my $single_redo;

around new => sub {
    my ( $orig, $class, %params ) = @_;
    my $self = $class->$orig(%params);
    $single_inst = $self;
    $single_redo and $self->{relevant_units} = _coerce_relevant_units($single_redo);
    return $self;
};

sub _build_relevant_units
{
    [ keys %{ $_[0]->unit_definitions } ];
}

sub _coerce_relevant_units
{
    my ($val) = @_;
    $single_inst or return $single_redo = $val;
    defined $val or die "Missing argument for relevant_units";
    ref $val eq "ARRAY" or die "Invalid type for relevant_units";
    my $neg = $val->[0] eq "!" and shift @$val;
    @$val or die "Missing elements for relevant_units";

    $single_inst or return $val;

    my @brkn;
    foreach my $ru ( @{$val} )
    {
        $neg = $ru eq "!" and next unless defined $neg;
        exists $single_inst->unit_definitions->{$ru}
          or push @brkn, $ru;
    }
    @brkn and die "Non-existing unit type(s): " . join( ", ", @brkn );

    $neg or return $val;

    my @neg_list = grep {
        my $item = $_;
        grep { $_ ne "!" and $_ ne $item } @{$val}
    } keys %{ $single_inst->unit_definitions };
    return \@neg_list;
}

option "unit_length" => (
                          is        => "ro",
                          doc       => "Allowes limitation of unit length",
                          format    => "i",
                          short     => "l",
                          predicate => 1,
                        );

option "deviation" => (
                        is        => "ro",
                        doc       => "Allowes limit deviation of unit elements by <einheit>",
                        format    => "i",
                        short     => "d",
                        predicate => 1,
                      );

with "App::Math::Tutor::Role::Exercise", "App::Math::Tutor::Role::Unit";

our $VERSION = '0.003';

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
