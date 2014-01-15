#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use MooX::Cmd::Tester;
use App::Math::Tutor;

my $rv;

$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(vulfrac add)] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(vulfrac mul)] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(vulfrac cast)] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(natural add)] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(roman add)] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(roman cast)] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(unit add)] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(unit cast)] );
$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(unit compare)] );

$rv = test_cmd_ok( 'App::Math::Tutor' => [qw(power rules)] );

done_testing;
