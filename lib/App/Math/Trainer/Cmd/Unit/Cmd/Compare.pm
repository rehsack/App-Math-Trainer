package App::Math::Trainer::Cmd::Unit::Cmd::Compare;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Cmd::Unit::Cmd::Compare - Plugin for comparing numbers with units

=cut

our $VERSION = '0.003';

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

with "App::Math::Trainer::Role::UnitExercise";

sub _build_exercises
{
    my ($self) = @_;

    my (@tasks);

    foreach my $i ( 1 .. $self->amount )
    {
        my @line;
        foreach my $j ( 0 .. 1 )
        {
            my ( $a, $b ) = $self->get_unit_numbers(2);
            push @line, [ $a, $b ];
        }
        push @tasks, \@line;
    }

    my $exercises = {
                      section    => "Unit comparison",
                      caption    => 'Units',
                      label      => 'unit_comparison',
                      header     => [ [ 'Unit Comparison', 'Unit Comparison' ] ],
                      solutions  => [],
                      challenges => [],
                    };

    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );

        foreach my $i ( 0 .. 1 )
        {
            my ( $a, $b ) = @{ $line->[$i] };
            push( @challenge, "\$ $a \\underline{\\texttt{ }}\\text{ } $b = \$" );

            my @way;    # remember Frank Sinatra :)
            my $op = $a <=> $b;
            $op < 0  and push( @way, "$a < $b" );
            $op > 0  and push( @way, "$a > $b" );
            $op == 0 and push( @way, "$a = $b" );

            push( @solution, '$ ' . join( " = ", @way ) . ' $' );
        }

        push( @{ $exercises->{solutions} },  \@solution );
        push( @{ $exercises->{challenges} }, \@challenge );
    }

    return $exercises;
}

1;
