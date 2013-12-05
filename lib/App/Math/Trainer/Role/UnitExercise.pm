package App::Math::Trainer::Role::UnitExercise;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer::Role::FracExercise - role for exercises in calculation with units

=cut

use Moo::Role;
use MooX::Options;

with "App::Math::Trainer::Role::Exercise", "App::Math::Trainer::Role::Unit";

our $VERSION = '0.003';

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2013 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
