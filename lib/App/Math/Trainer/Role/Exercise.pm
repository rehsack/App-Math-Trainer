package App::Math::Trainer::Role::Exercise;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer::Role::Exercise - basic role for getting exercises

=cut

use Moo::Role;
use MooX::Options;

our $VERSION = '0.002';

=head1 ATTRIBUTES

=head2 amount

Specifies amount of calculations to generate

=cut

option amount => (
                   is      => "ro",
                   doc     => "Specifies amount of exercises to generate",
		   long_doc => "Specify amount of exercises to generate. In " .
		   "case of several kind of exercises, \$amount exercises " .
		   "are generated per kind.",
                   format  => "i",
                   short   => "n",
                   default => sub { 25 },
                 );

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2013 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
