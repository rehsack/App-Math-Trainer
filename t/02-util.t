#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use App::Math::Tutor::Util qw(:all);
use App::Math::Tutor::Numbers;

my ( $p, $q, $d, $formatted );

$p = VulFracNum->new( num   => -7,
                      denum => 4 );
$q = VulFracNum->new( num   => 3,
                      denum => 4 );    # no complex ftm
$d = PolyNum->new(
                   values => [
                               VulFracNum->new(
                                                num   => $p,
                                                denum => 2
                                              ),
                               $q
                             ],
                   operator => "-",
                 );
$formatted = sumcat_terms(
                           '\pm',
                           VulFracNum->new(
                                            num   => $p,
                                            denum => 2,
                                            sign  => -1
                                          ),
                           Power->new(
                                       basis => $d,
                                       exponent =>
                                         VulFracNum->new(
                                                          num   => 1,
                                                          denum => 2
                                                        ),
                                       mode => 1
                                     )
                         );

is( $formatted,
    '\frac{\frac{7}{4}}{2}\pm\sqrt{-\left(\frac{\frac{7}{4}}{2}\right)-\frac{3}{4}}',
    'format -p/2 +/- sqrt(d) with p < 0' );

$p = VulFracNum->new( num   => 7,
                      denum => 4 );
$q = VulFracNum->new( num   => 3,
                      denum => 4 );    # no complex ftm
$d = PolyNum->new(
                   values => [
                               VulFracNum->new(
                                                num   => $p,
                                                denum => 2
                                              ),
                               $q
                             ],
                   operator => "-",
                 );
$formatted = sumcat_terms(
                           '\pm',
                           VulFracNum->new(
                                            num   => $p,
                                            denum => 2,
                                            sign  => -1
                                          ),
                           Power->new(
                                       basis => $d,
                                       exponent =>
                                         VulFracNum->new(
                                                          num   => 1,
                                                          denum => 2
                                                        ),
                                       mode => 1
                                     )
                         );
is( $formatted,
    '-\left(\frac{\frac{7}{4}}{2}\right)\pm\sqrt{\frac{\frac{7}{4}}{2}-\frac{3}{4}}',
    'format -p/2 +/- sqrt(d) with p > 0' );

my ( $a, $b );

$a = VulFracNum->new(
                      num => PolyNum->new(
                                           operator => "+",
                                           values   => [ NatNum->new( value => 27 ), 14 ]
                                         ),
                      denum => 5
                    );
$b = VulFracNum->new(
                      num => PolyNum->new(
                                           operator => "+",
                                           values   => [ NatNum->new( value => 15 ), 13 ]
                                         ),
                      denum => 9
                    );

$formatted = prodcat_terms( "/", $a, $b );
is( $formatted, '\frac{27+14}{5}\div{}\frac{15+13}{9}', "a / b" );

done_testing;
