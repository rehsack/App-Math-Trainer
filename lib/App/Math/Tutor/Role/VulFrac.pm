package App::Math::Tutor::Role::VulFrac;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Role::VulFrac - role for vulgar fraction numbers

=cut

use Moo::Role;
use App::Math::Tutor::Numbers;

our $VERSION = '0.004';

sub _check_vulgar_fraction
{
    $_[0]->num >= 2 and $_[0]->denum >= 2 and $_[0]->num % $_[0]->denum != 0;
}

requires "format";

sub _guess_vulgar_fraction
{
    my ( $max_num, $max_denum ) = @{ $_[0]->format };
    my ( $num, $denum ) = ( int( rand($max_num) ), int( rand($max_denum) ) );
    return
      VulFracNum->new( num   => $num,
                       denum => $denum );
}

sub get_vulgar_fractions
{
    my ( $self, $amount ) = @_;
    my @result;

    while ( $amount-- )
    {
        my $vf;
        do
        {
            $vf = $self->_guess_vulgar_fraction;
        } while ( !_check_vulgar_fraction($vf) );

        push @result, $vf;
    }

    return @result;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
