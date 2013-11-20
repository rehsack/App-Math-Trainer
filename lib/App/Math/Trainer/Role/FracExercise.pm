package App::Math::Trainer::Role::FracExercise;

use warnings;
use strict;

use Moo::Role;
use MooX::Options;

with "App::Math::Trainer::Role::Exercise";

option format => (
    is  => "ro",
    doc => "specifies format of numerator/denominator",
    isa => sub {
        defined( $_[0] )
          and !ref $_[0]
	  and $_[0] !~ m/^\d?n+(?::\d?n+)?$/
          and die("Invalid format");
    },
    coerce => sub {
        defined( $_[0] )
          or return [ 100, 100 ];
        ref $_[0] eq "ARRAY" and return $_[0];

        my ( $fmta, $fmtb ) = ( $_[0] =~ m/^(\d?n+)(?::(\d?n+))?$/ );
        defined $fmtb or $fmtb = $fmta;
        my $starta = "1";
        my $startb = "1";
        $fmta =~ s/^(\d)(.*)/$2/ and $starta = $1;
        $fmtb =~ s/^(\d)(.*)/$2/ and $startb = $1;
        my $maxa = $starta . "0" x length($fmta);
        my $maxb = $startb . "0" x length($fmtb);
	[ $maxa, $maxb ];
    },
    default => sub { return [ 100, 100 ]; },
    format  => "s",
    short   => "n",
                 );

1;
