package App::Math::Trainer;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer - lets parents generate training lessons in Math

=cut

our $VERSION = '0.001';

use App::Cmd::Setup -app;

=head1 SYNOPSIS

  # generates 25 addition and subtraction aufgaben (25 each)
  math-train add -n 25 -f nnn:nnn -r "0]..1"
  # generates 25 multiplication and division aufgaben (40 each)
  math-train mul -n 40 -f  nn:nnn -r "0]..1"

=head1 DESCRIPTION

Provides a command line tool to generate math (calculating) training
lessons for their children.

=head1 AUTHOR

Jens Rehsack, C<< <rehsack at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-app-math-trainer at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Math-Trainer>.  I
will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Math::Trainer

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Math-Trainer>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Math-Trainer>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Math-Trainer>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Math-Trainer/>

=back

I try to answer any support request within a week and tell how fast it's
probably solved and a fix is released. However, this is free time and it's
spare. Please be patient or buy support to receive an answer in a
guaranteed time.

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of App::Math::Trainer
