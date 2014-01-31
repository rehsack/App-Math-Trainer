#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use MooX::Cmd::Tester;
use App::Math::Tutor;

use File::Path qw(mkpath rmtree);

my $test_dir = $ENV{TEST_DIR};
my $keep     = $ENV{KEEP_TEST_OUTPUT};

BEGIN
{
    if ( defined($test_dir) )
    {
        $keep = 1;
    }
    else
    {
        $test_dir = File::Spec->rel2abs( File::Spec->curdir() );
        $test_dir = File::Spec->catdir( $test_dir, "test_output_" . $$ );
        $test_dir = VMS::Filespec::unixify($test_dir) if $^O eq 'VMS';
        rmtree $test_dir;
        mkpath $test_dir;
    }
}

END { !$keep and defined($test_dir) and rmtree $test_dir }

my $rv;

$rv = test_cmd_ok(
         'App::Math::Tutor' => [ qw(vulfrac add --output-type tex --output-location), $test_dir ] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(vulfrac mul -t tex -o),     $test_dir ] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(vulfrac cast -t tex -o),    $test_dir ] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(vulfrac compare -t tex -o), $test_dir ] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(natural add -t tex -o), $test_dir ] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(roman add -t tex -o),  $test_dir ] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(roman cast -t tex -o), $test_dir ] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(unit add -t tex -o),     $test_dir ] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(unit cast -t tex -o),    $test_dir ] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(unit compare -t tex -o), $test_dir ] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(poly solve -t tex -o), $test_dir ] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(power rules -t tex -o), $test_dir ] );

done_testing;
