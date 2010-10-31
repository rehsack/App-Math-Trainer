#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Math::Trainer' ) || print "Bail out!
";
}

diag( "Testing App::Math::Trainer $App::Math::Trainer::VERSION, Perl $], $^X" );
