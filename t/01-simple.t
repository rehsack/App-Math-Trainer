#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use MooX::Cmd::Tester;
use App::Math::Tutor;

use File::Path qw(mkpath rmtree);

my $test_dir;
my $keep;

BEGIN
{
    defined $ENV{KEEP_TEST_OUTPUT} and $keep = $ENV{KEEP_TEST_OUTPUT};
    if ( defined( $ENV{TEST_DIR} ) )
    {
        $test_dir = $ENV{TEST_DIR};
        -d $test_dir or mkpath $test_dir;
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

END { defined($test_dir) and rmtree $test_dir unless $keep }

my $rv;

$rv = test_cmd_ok( 'App::Math::Tutor' => [ qw(vulfrac add --output-type tex --output-location), $test_dir ] );
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
