package App::Math::Tutor::Role::Exercise;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::Exercise - basic role for getting exercises

=cut

use Moo::Role;
use MooX::Options;

use Carp qw(croak);
use File::Spec     ();
use File::ShareDir ();
use Template       ();

our $VERSION = '0.003';

=head1 ATTRIBUTES

=head2 amount

Specifies amount of calculations to generate

=cut

option amount => (
                   is       => "ro",
                   doc      => "Specifies amount of exercises to generate",
                   long_doc => "Specify amount of exercises to generate. In "
                     . "case of several kind of exercises, \$amount exercises "
                     . "are generated per kind.",
                   format  => "i",
                   short   => "n",
                   default => sub { 15 },
                 );

=head2 exercises

Lazy hash containing the exercises to fill into the template.

Expected attribute:

=over 4

=item section

The caption of the section containing the challenges. The solutions section
will reuse the section caption prepended by I<Solution:>.

=item caption

Table caption for challenges table. The solutions table will be prepended
by the word I<Solution>.

=item label

Label of the table containing the challenges - the solutions table will
be the given label prepended by I<solution>.

=item header

List of table headers - one header per column

=item challenges

List of challenges to exercise

=item solutions

List of solutions of challenges

=back

=cut

has exercises => (
    is => "lazy",
    # requires _build_exercises
                 );

=head2 output_name

Lazy string representing the basename without extension of the output
file. The default builder returns the names of all commands in chain
joined with empty string.

=cut

has output_name => (
                     is => "lazy",
                   );

sub _build_output_name
{
    my $self = shift;

    my $cmdnames = join( "", map { $_->command_name || "" } @{ $self->command_chain } );

    return $cmdnames;
}

=head1 REQUIRED ATTRIBUTES

=head2 template_filename

The basename of the template file for processing to get the exercises.

=cut

requires "template_filename";

sub execute
{
    my $self = shift;

    my $exercises = $self->exercises;

    my $sharedir = File::ShareDir::dist_dir("App-Math-Tutor");
    my $ttcpath = File::Spec->catfile( $sharedir, $self->template_filename . ".tt2" );

    my $template = Template->new(
                                  {
                                    ABSOLUTE => 1,
                                  }
                                );
    my $rc = $template->process(
                                 $ttcpath,
                                 {
                                    exercises => $exercises,
                                    output    => {
                                                format => 'pdf',
                                              },
                                 },
                                 $self->output_name . ".pdf"
                               );
    $rc or croak( $template->error() );

    return 0;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
