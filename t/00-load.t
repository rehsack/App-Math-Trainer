#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Math::Trainer' ) || BAIL_OUT "Couldn't load App::Math::Trainer!";
}

diag( "Testing App::Math::Trainer $App::Math::Trainer::VERSION, Perl $], $^X" );
