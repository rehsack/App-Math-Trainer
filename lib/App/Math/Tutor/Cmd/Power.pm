package App::Math::Tutor::Cmd::Power;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Cmd::Power - namespace for exercises for power mathematics

=cut

our $VERSION = '0.006';

use Moo;
use MooX::Cmd;
use MooX::Options;

sub execute
{
    shift->options_usage();
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
