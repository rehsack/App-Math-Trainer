package App::Math::Tutor::Numbers;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Numbers - Numbers provider for math exercises

=cut

use App::Math::Tutor::Util ();

our $VERSION = '0.004';

{
    package    #
      VulFrac;

    use Moo;
    use overload
      '""'   => "_stringify",
      '0+'   => "_numify",
      'bool' => sub { $_[0]->num != 0 },
      '<=>'  => "_num_compare";

    use Carp qw/croak/;
    use Scalar::Util qw/blessed dualvar/;

    has num => (
                 is       => "ro",
                 required => 1
               );

    has denum => (
                   is       => "ro",
                   required => 1
                 );
    has sign => (
                  is       => "ro",
                  required => 1,
                );

    around BUILDARGS => sub {
        my $orig   = shift;
        my $self   = shift;
        my $params = $self->$orig(@_) or return;
        defined $params->{sign} or $params->{sign} = 1;
        $params->{num} < 0   and $params->{sign} *= -1;
        $params->{denum} < 0 and $params->{sign} *= -1;
        $params->{sign} = $params->{sign} < 0 ? dualvar( -1, "-" ) : dualvar( 1, "" );
        $params->{num} = blessed $params->{num} ? $params->{num}->_abs : abs( $params->{num} );
        $params->{denum} =
          blessed $params->{denum} ? $params->{denum}->_abs : abs( $params->{denum} );
        $params;
    };

    sub _stringify
    {
        $_[0]->denum == 1 and return $_[0]->num;
        $_[1]
          and $_[0]->num > $_[0]->denum
          and return
          sprintf( '%s\normalsize{%d} \frac{%d}{%d}',
                   $_[0]->sign,
                   int( $_[0]->_numify ),
                   $_[0]->num - $_[0]->denum * int( $_[0]->_numify ),
                   $_[0]->denum );
        return "" . $_[0]->sign . "\\frac{" . $_[0]->num . "}{" . $_[0]->denum . "}";
    }

    sub _numify
    {
        my $rc = eval sprintf( "(%s%s)/(%s)", $_[0]->sign, $_[0]->num, $_[0]->denum );
        $@ and croak $@;
        return $rc;
    }

    sub _num_compare
    {
        my ( $self, $other, $swapped ) = @_;
        $swapped and return $other <=> $self->_numify;

        blessed $other or return $self->_numify <=> $other;
        return $self->_numify <=> $other->_numify;
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
        my ( $a, $b ) = ( $_[0]->num, $_[0]->denum );
        my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
        return $gcd;
    }

    sub _reduce
    {
        my ( $a, $b ) = ( $_[0]->num, $_[0]->denum );
        my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
        return
          VulFrac->new(
                        num   => $_[0]->num / $gcd,
                        denum => $_[0]->denum / $gcd,
                        sign  => $_[0]->sign
                      );
    }

    sub _reciprocal
    {
        return
          VulFrac->new(
                        num   => $_[0]->denum,
                        denum => $_[0]->num,
                        sign  => $_[0]->sign
                      );
    }

    sub abs
    {
        return
          VulFrac->new(
                        num   => $_[0]->denum,
                        denum => $_[0]->num,
                        sign  => 1
                      );
    }
}

{
    package    #
      NatNum;

    use Moo;
    use overload
      '""'   => "_stringify",
      '0+'   => "_numify",
      'bool' => sub { $_[0]->value != 0 },
      '<=>'  => "_num_compare";

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has value => (
                   is       => "ro",
                   required => 1
                 );

    sub _stringify { "" . $_[0]->value }
    sub _numify    { $_[0]->value }

    sub _num_compare
    {
        my ( $self, $other, $swapped ) = @_;
        $swapped and return $other <=> $self->_numify;

        blessed $other or return $self->_numify <=> $other;
        return $self->_numify <=> $other->_numify;
    }

    sub sign { return $_[0]->value <=> 0 }
    sub _abs { return NatNum->new( value => abs( $_[0]->value <=> 0 ) ) }
}

{
    package    #
      PolyTerm;

    use Moo;
    use overload
      '""'   => "_stringify",
      'bool' => sub { $_[0]->factor != 0 };

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has factor => (
                    is       => "ro",
                    required => 1
                  );
    has exponent => (
                      is       => "ro",
                      required => 1
                    );

    sub _stringify
    {
        my ($self) = @_;
        my ( $fact, $exp ) = ( $self->factor, $self->exponent );
        $fact or return;
        0 == $exp and return "$fact";    #sprintf( "%s$fact", $fact >= 0 ? "+" : "" );
        1 == $exp
          and 1 != $fact
          and return "{$fact}x";         #sprintf( "{%s$fact}x", $fact >= 0 ? "+" : "" );
        1 == $exp  and return "x";
        1 == $fact and return "x^{$exp}";
        return sprintf( "{%s}x^{%s}", $fact, $exp );
    }

    sub _abs
    {
        my ( $fact, $exp ) = ( $_[0]->factor, $_[0]->exponent );
        $fact = blessed $fact ? $fact->abs() : abs($fact);
        return
          PolyTerm->new( factor   => $fact,
                         exponent => $exp );
    }

    sub sign { return $_[0]->factor <=> 0 }
}

{
    package    #
      PolyNum;

    use Moo;
    use overload
      '""'   => "_stringify",
      'bool' => sub { 1 };      # XXX prodcat(values->as_bool)

    use Carp qw/croak/;
    App::Math::Tutor::Util->import(qw(sumcat_terms));

    has values => (
                    is       => "ro",
                    required => 1
                  );

    sub _stringify { sumcat_terms( "+", reverse @{ $_[0]->values } ); }
}

{
    package    #
      Power;

    use Moo;
    use overload
      '""'   => "_stringify",
      '0+'   => "_numify",
      'bool' => sub { $_[0]->basis != 0 },    # 0 ** 7 == 0
      '<=>'  => "_num_compare";

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has basis => (
                   is       => "ro",
                   required => 1
                 );

    has exponent => (
                      is       => "ro",
                      required => 1
                    );

    has mode => (
                  is      => "rw",
                  default => sub { 0 },
                );

    sub _stringify
    {
        $_[0]->exponent == 1 and return $_[0]->basis;
        $_[0]->mode or return join( "^", $_[0]->basis, $_[0]->exponent );
        return
          sprintf( "\\sqrt[%s]{%s}",
                   blessed( $_[0]->exponent ) ? $_[0]->exponent->denum : $_[0]->exponent,
                   blessed( $_[0]->exponent )
                     && $_[0]->exponent->num > 1
                   ? sprintf( "{%s}^{%s}", $_[0]->basis, $_[0]->exponent->num )
                   : $_[0]->basis );
    }

    sub _numify
    {
        my $rc = eval sprintf( "(%d)**(%d)", $_[0]->basis, $_[0]->exponent );
        $@ and croak $@;
        return $rc;
    }

    sub _num_compare
    {
        my ( $self, $other, $swapped ) = @_;
        $swapped and return $other <=> $self->_numify;

        blessed $other or return $self->_numify <=> $other;
        return $self->_numify <=> $other->_numify;
    }

    sub _reduce
    {
        die "mising";
    }
}

{
    package    #
      RomanNum;

    use Moo;

    extends "NatNum";

    use Carp qw/croak/;

    around BUILDARGS => sub {
        my $next   = shift;
        my $class  = shift;
        my $params = $class->$next(@_);
        defined $params->{value}
          and $params->{value} < 1
          and croak( "Roman numerals starts at I - " . $params->{value} . " is to low" );
        defined $params->{value}
          and $params->{value} > 3888
          and
          croak( "Roman numerals ends at MMMDCCCLXXXVIII - " . $params->{value} . " is to big" );
        return $params;
    };

    my %sizes = (
                  M  => 1000,
                  CM => 900,
                  D  => 500,
                  CD => 400,
                  C  => 100,
                  XC => 90,
                  L  => 50,
                  XL => 40,
                  X  => 10,
                  IX => 9,
                  V  => 5,
                  IV => 4,
                  I  => 1,
                );

    sub _stringify
    {
        my $self  = $_[0];
        my $value = $self->value;
        my $str   = "";
        my @order = sort { $sizes{$b} <=> $sizes{$a} } keys %sizes;
        foreach my $sym (@order)
        {
            while ( $value >= $sizes{$sym} )
            {
                $str .= $sym;
                $value -= $sizes{$sym};
            }
        }
        return $str;
    }
}

{
    package    #
      Unit;

    use Moo;
    use overload
      '""'   => "_stringify",
      '0+'   => "_numify",
      'bool' => "_filled",
      '<=>'  => "_num_compare";
    use Scalar::Util qw/blessed/;

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
                   is       => "ro",
                   required => 1
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
        my @parts    = @{ $_[0]->parts };
        my $base     = $_[0]->type->{base};
        my $spectrum = $_[0]->type->{spectrum};
        my $res      = 0;
        for my $i ( $_[0]->begin .. $_[0]->end )
        {
            my $num = shift @parts;
            $num or next;
            my $factor = $spectrum->[$i]->{factor};
            $res = $i <= $base ? $res + $num * $factor : $res + $num / $factor;
        }

        if ( defined $_[1] )
        {
            my $factor = $spectrum->[ $_[1] ]->{factor};
            $res = $_[1] <= $base ? $res / $factor : $res * $factor;
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

        blessed $other or return $self->_numify <=> $other;
        my $rc;
        0 != ( $rc = $other->begin <=> $self->begin )
          and return $rc;    # $self->begin < $other->begin => $self > $other
        return $self->_numify <=> $other->_numify;
    }
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
