package App::Math::Trainer::Cmd::Unit::Cmd::Add;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Trainer::Cmd::Unit::Cmd::Add - Plugin for addition and subtraction of numbers with units

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
                      section    => "Unit addition / subtraction",
                      caption    => 'Units',
                      label      => 'unit_addition',
                      header     => [ [ 'Unit Addition', 'Unit Subtraction' ] ],
                      solutions  => [],
                      challenges => [],
                    };

    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );

        foreach my $i ( 0 .. 1 )
        {
            my ( $a, $b ) = @{ $line->[$i] };
            my $op = $i ? '-' : '+';
            $op eq '-' and $a < $b and ( $b, $a ) = ( $a, $b );
            push( @challenge, "\$ $a $op $b = \$" );

            my @way;    # remember Frank Sinatra :)
            push( @way, "$a $op $b" );
            my $beg = $a->begin < $b->begin ? $a->begin : $b->begin;
            my $end = $a->end > $b->end     ? $a->end   : $b->end;
            my @ap  = @{ $a->parts };
            my @bp  = @{ $b->parts };
            my ( @cparts, @dparts );
            for my $i ( $beg .. $end )
            {
                my @cps;
                $i >= $a->begin and $i <= $a->end and push( @cps, shift @ap );
                $i >= $b->begin and $i <= $b->end and push( @cps, shift @bp );
                scalar @cps or next;
                my $cp = join( " $op ", @cps );
                my $dp = eval "$cp;";
                if ( $dp < 0 )
                {
                    --$dparts[-1];
                    $dp += $a->type->{spectrum}->[$i]->{max} + 1;
                }
                push( @cparts, $cp );
                push( @dparts, $dp );
            }
            my $c = Unit->new(
                               type  => $a->type,
                               begin => $beg,
                               end   => $end,
                               parts => \@cparts
                             );
            my $d = Unit->new(
                               type  => $a->type,
                               begin => $beg,
                               end   => $end,
                               parts => \@dparts
                             );

            push( @way, "$c" );
            push( @way, "$d" );

            push( @solution, '$ ' . join( " = ", @way ) . ' $' );
        }

        push( @{ $exercises->{solutions} },  \@solution );
        push( @{ $exercises->{challenges} }, \@challenge );
    }

    return $exercises;
}

1;