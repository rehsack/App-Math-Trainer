package App::Math::Tutor::Cmd::Poly::Cmd::Solve;

use warnings;
use strict;

use vars qw(@ISA $VERSION);

=head1 NAME

App::Math::Tutor::Cmd::Poly::Cmd::Solve - Plugin for solving polynoms

=cut

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options;

use Carp qw(croak);

has template_filename => (
                           is      => "ro",
                           default => "onecolmlsol"
                         );
use Module::Runtime qw/require_module/;

require_module 'App::Math::Tutor::Role::VulFrac';    # we only want VulFrac type

with "App::Math::Tutor::Role::PolyExercise";

use Math::Prime::Util qw(factor prime_precalc);

=head2 complex_solution

Specifies whether solution can become complex or not

=cut

option complex_solution => (
                             is       => "ro",
                             doc      => "Specifies whether solution can become complex or not",
                             long_doc => "Hand's over control whether the solution has to be "
                               . "a 'real' number or can get complex, respectively.\n\n"
                               . "Default: no",
                             default     => sub { return 0; },
                             short       => "c",
                             negativable => 1,
                           );

sub _extract_sqrt
{
    my ( $self, $num, $exp ) = @_;
    my @nf = factor( abs($num) );
    my %nf;
    ++$nf{$_} for (@nf);
    my $bf = 1;
    my $rm = 1;
    foreach my $n ( sort keys %nf )
    {
        my $o = delete $nf{$n};
        my $c = $o;
        $c -= $exp while ( $c >= $exp );
        $c and $rm *= $c * $n;
        $o != $c and $bf *= $n**( ( $o - $c ) / $exp );
    }
    return ( $bf, $rm );
}

sub _check_sqrt
{
    my ( $self, $num, $exp ) = @_;
    my ( $bf, $rm ) = $self->_extract_sqrt( $num, $exp );
    my $format = $self->format;
    return $rm <= $format;
}

around _check_polynom => sub {
    my $orig = shift;
    my $self = shift;
    $self->$orig(@_) or return;

    my @values = reverse @{ $_[0]->values };
    $values[0]->exponent == 2 or return;    # XXX
    my @fac = (0) x $values[0]->exponent;
    $fac[ $_->exponent ] = $_->factor for (@values);
    my ( $a, $b, $c ) =
      @fac;    # ( $values[0]->factor, $values[1]->factor || 0, $values[2]->factor || 0 );
    $a == 0 and return;
    my ( $p, $q ) = (
                      VulFrac->new(
                                    num   => $b,
                                    denum => $a
                        )->_reduce,
                      VulFrac->new(
                                    num   => $c,
                                    denum => $a
                        )->_reduce
                    );
    my $p2 = VulFrac->new(
                           num   => $p->num * $p->num,
                           denum => $p->denum * $p->denum * 4
                         )->_reduce;
    my $gcd = VulFrac->new(
                            num   => $p2->denum,
                            denum => $q->denum
                          )->_gcd;
    my ( $fp, $fq ) = ( $q->{denum} / $gcd, $p2->{denum} / $gcd );
    my $d = VulFrac->new( num   => $p2->num * $fp - $q->num * $fq,
                          denum => $p2->denum * $fp );
    $d->num < 0 and !$self->complex_solution and return;
    $d->{num} = abs( $d->{num} );
    $d = $d->_reduce;
    return $self->_check_sqrt( $d->num, $values[0]->exponent )
      and $self->_check_sqrt( $d->denum, $values[0]->exponent );
};

sub _get_quad_solution
{
    my ( $self, $poly ) = @_;
    my ( @orig, @way, @solution );
    push @orig, 0, "$poly";

    my @values = @{ $poly->values };
    my @rvalues;
    my @pqvalues;
    my $reduced = 0;
    my $a_f     = $values[-1]->factor;
    my ( $p, $q ) = ( 0, 0 );
    foreach my $i ( 0 .. $#values - 1 )
    {
        my $exp = $values[$i]->exponent;
        my $f = VulFrac->new( num   => $values[$i]->factor,
                              denum => $a_f );
        push(
              @pqvalues,
              PolyTerm->new(
                             factor   => $f,
                             exponent => $exp
                           )
            );
        $f->_gcd > 1 and ++$reduced and $f = $f->_reduce;
        push(
              @rvalues,
              PolyTerm->new(
                             factor   => $f,
                             exponent => $exp
                           )
            );
        0 == $exp and $q = $f;
        1 == $exp and $p = $f;
    }
    push(
          @pqvalues,
          PolyTerm->new(
                         factor   => 1,
                         exponent => $values[-1]->exponent
                       )
        );
    push(
          @rvalues,
          PolyTerm->new(
                         factor   => 1,
                         exponent => $values[-1]->exponent
                       )
        );
    $reduced and push @orig, PolyNum->new( values => \@pqvalues );
    push( @orig, PolyNum->new( values => \@rvalues ) );

    push( @solution, '$ ' . join( " = ", @orig ) . ' $' );

    my $p_op = ( $p >= 0 ) ? "-" : "";
    my $q_op = ( $q >= 0 ) ? "-" : "+";

    push @way, "X_{1/2}";
    push @way,
      sprintf(
            '-\left(\frac{%s}{2}\right) \pm \sqrt{{\left(\frac{%s}{2}\right)}^2 - \left(%s\right)}',
            $p, $p, $q );

    my ( $D, $P, $Q, $P2, $SGN, $SQRT_D, @TERMS ) = ( 0, 0, 0, 0, 1 );
          $p != 0
      and $P = sprintf( '\frac{%d}{%d \cdot %d}', $p->num, $p->denum, 2 )
      and $P2 = sprintf( '{\left(%s\right)}^2', $P )
      and push @TERMS, "-$P";
    $q != 0 and $Q = $q;
    $SQRT_D = sprintf( '\pm\sqrt{%s}', join( " - ", grep { $_ } ( $P2, $Q ) ) )
      and push @TERMS, $SQRT_D
      if $p != 0 or $q != 0;
    push @way, join( '', @TERMS );

    $p != 0
      and $P = VulFrac->new(
                             num   => $p->num,
                             denum => 2 * $p->denum,
                             sign  => $p->sign . "1"
                           )->_reduce;

    if ( $p != 0 and $q != 0 )
    {
        @TERMS = ();
        $P2 = VulFrac->new(
                            num   => $P->num * $P->num,
                            denum => $P->denum * $P->denum
          )->_reduce
          and push @TERMS, "-$P";
        $q != 0 and $Q = $q;
        $SQRT_D = sprintf( '\sqrt{%s}', join( " - ", grep { $_ } ( $P2, $Q ) ) )
          and push @TERMS, $SQRT_D
          if $p != 0 or $q != 0;
        push @way, join( '\pm', @TERMS );

        my $gcd = VulFrac->new(
                                num   => $P2->denum,
                                denum => $Q->denum
                              )->_gcd;
        my ( $fP, $fQ ) = ( $Q->{denum} / $gcd, $P2->{denum} / $gcd );

        @TERMS = ("-$P");
        $SQRT_D =
          sprintf( '\sqrt{\frac{%d \cdot %d}{%d \cdot %d} - \frac{%d \cdot %d}{%d \cdot %d}}',
                   $P2->num, $fP, $P2->denum, $fP, $Q->num, $fQ, $Q->denum, $fQ );
        push @TERMS, $SQRT_D;
        push @way, join( '\pm', @TERMS );

        @TERMS = ("-$P");
        $SQRT_D = sprintf(
                           '\sqrt{\frac{%d}{%d} - \frac{%d}{%d}}',
                           $P2->num * $fP,
                           $P2->denum * $fP,
                           $Q->num * $fQ,
                           $Q->denum * $fQ
                         );
        push @TERMS, $SQRT_D;
        push @way, join( '\pm', @TERMS );

        @TERMS = ("-$P");
        $SQRT_D =
          sprintf( '\sqrt{\frac{%d - %d}{%d}}', $P2->num * $fP, $Q->num * $fQ, $P2->denum * $fP );
        push @TERMS, $SQRT_D;
        push @way, join( '\pm', @TERMS );

        @TERMS = ("-$P");
        $D = VulFrac->new( num   => $P2->num * $fP - $Q->num * $fQ,
                           denum => $P2->denum * $fP );
        $D->num < 0
          and $SGN = -1
          and $D   = VulFrac->new(
                                 num   => -1 * $D->num,
                                 denum => $D->denum );
        my $SQRT_D = sprintf( '\sqrt{%s%s}', $SGN < 0 ? "-" : "", $D );
        push @TERMS, $SQRT_D;
        push @way, join( '\pm', @TERMS );

        if ( $D->_gcd > 1 )
        {
            @TERMS = ("-$P");
            $D     = $D->_reduce;
            my $SQRT_D = sprintf( '\pm\sqrt{%s%s}', $SGN < 0 ? "-" : "", $D );
            push @TERMS, $SQRT_D;
            push @way, join( '', @TERMS );
        }
    }
    elsif ( $p != 0 )
    {
        # if $p can ever be < 0: XXX
        @TERMS = ( "-$P", "$P" );
        push @way, join( '\mp', @TERMS );
        $D = $P;
    }
    elsif ( $q != 0 )
    {
        $D = $Q;
        $SQRT_D = sprintf( '\pm\sqrt{-{%s}}', $D );
        push @way, $SQRT_D;
        $SGN = -1;
    }

    if ($SQRT_D)
    {
        my ( $i, @ST ) = 0;
        @TERMS = ();
        $p != 0 and push @TERMS, "-$P";
        my ( $bfn, $rmn ) = $self->_extract_sqrt( $D->num,   2 );
        my ( $bfd, $rmd ) = $self->_extract_sqrt( $D->denum, 2 );
        if ( $bfn != 1 and $bfd != 1 and $rmn != 1 and $rmd != 1 )
        {
            my $SQRT_ED =
              sprintf( '\pm\frac{%d}{%d}\frac{\sqrt{%d}}{\sqrt{%d}}', $bfn, $bfd, $rmn, $rmd );
            $SQRT_D ne $SQRT_ED and push @way, join( "", ( @TERMS, $SQRT_ED ) );
        }
        else
        {
            if ( $rmn != 1 )
            {
                my $SQRT_ED =
                  sprintf( '\pm\frac{%s\sqrt{%d}}{%d}', $bfn != 1 ? $bfn : "", $rmn, $bfd );
                $SQRT_D ne $SQRT_ED and push @way, join( "", ( @TERMS, $SQRT_ED ) );
            }
            elsif ( $rmd != 1 )
            {
                my $SQRT_ED =
                  sprintf( '\pm\frac{%d}{%s\sqrt{%d}}', $bfn, $bfd != 1 ? $bfd : "", $rmd );
                $SQRT_D ne $SQRT_ED and push @way, join( "", ( @TERMS, $SQRT_ED ) );
            }
        }
    }

    push( @solution, '$ ' . join( " = ", @way ) . ' $' );

    return @solution;
}

sub _build_exercises
{
    my ($self) = @_;
    my (@tasks);
    my $mf = Math::Prime::Util::MemFree->new;

    foreach my $i ( 1 .. $self->quantity )
    {
        my @line;
        push @line,  $self->get_polynom(1);
        push @tasks, \@line;
    }

    my $exercises = {
                      section    => "Polynom Solving",
                      caption    => 'Polynoms',
                      label      => 'polynom_solving',
                      header     => [ ['Polynom Solve'] ],
                      solutions  => [],
                      challenges => [],
                    };

    foreach my $line (@tasks)
    {
        my ( @solution, @challenge );

        my ($a) = @{$line};
        push( @challenge, "\$ $a = 0 \$" );
        $a->values->[-1]->exponent > 2 and die "No way to solve polynoms of power 3 or higher";
        $a->values->[-1]->exponent == 2 and push @solution, $self->_get_quad_solution($a);

        push( @{ $exercises->{solutions} },  \@solution );
        push( @{ $exercises->{challenges} }, \@challenge );
    }

    return $exercises;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
