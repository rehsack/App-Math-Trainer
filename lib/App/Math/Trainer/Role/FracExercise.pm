package App::Math::Trainer::Role::FracExercise;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer::Role::FracExercise - role for exercises in vulgar fraction

=cut

use Moo::Role;
use MooX::Options;

with "App::Math::Trainer::Role::Exercise";

our $VERSION = '0.002';

=head1 ATTRIBUTES

=head2 format

Specifies format of numerator/denominator

=cut

option format => (
    is  => "ro",
    doc => "specifies format of numerator/denominator",
    long_doc => "Allow specifying the format of the numerator/denominator " .
    "as vulgar fraction is typed with 'n' as placeholder:\n\n" .
    "\t--format 5nnn/nn\n\n" .
    "creates vulgar fractions from 5999/99 .. 0001/01.\n\n" .
    "Defailt: 100/100",
    isa => sub {
        defined( $_[0] )
          and !ref $_[0]
	  and $_[0] !~ m,^\d?n+(?:/\d?n+)?$,
          and die("Invalid format");
    },
    coerce => sub {
        defined( $_[0] )
          or return [ 100, 100 ];
        ref $_[0] eq "ARRAY" and return $_[0];

        my ( $fmta, $fmtb ) = ( $_[0] =~ m,^(\d?n+)(?:/(\d?n+))?$, );
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
    short   => "f",
                 );

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2013 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
