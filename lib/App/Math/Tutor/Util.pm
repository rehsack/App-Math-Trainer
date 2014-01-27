package App::Math::Tutor::Util;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Util - Utilities for easier Math Tutorial Exercises generation

=cut

use vars qw();

use Exporter;

our $VERSION = '0.004';
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw(sumcat_terms);
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

my %sum_opposites = (
'+' => '-',
'-' => '+',
'\pm' => '\mp',
'\mp' => '\pm',);

sub sumcat_terms
{
    my ($op, @terms) = @_;
    ...
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
