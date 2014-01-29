package App::Math::Tutor::Util;

use warnings;
use strict;

=head1 NAME

App::Math::Tutor::Util - Utilities for easier Math Tutorial Exercises generation

=cut

use vars qw();

use Exporter;

our $VERSION     = '0.004';
our @ISA         = qw(Exporter);
our @EXPORT      = qw();
our @EXPORT_OK   = qw(sumcat_terms);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

use Scalar::Util qw/blessed/;

my %sum_opposites = (
                      '+'   => '-',
                      '-'   => '+',
                      '\pm' => '\mp',
                      '\mp' => '\pm',
                    );

=head1 EXPORTS

=head2 sumcat_terms

  my $formatted = sumcat_terms( "-", "", VulFrac->new( num => $p, denum => 2 ), 

=cut

sub sumcat_terms
{
    my ( $op, @terms ) = @_;
    my $str = "" . shift @terms;

    foreach my $term (@terms)
    {
        $term or next;
        my $c_op = $op;
        my $sign = blessed $term ? $term->sign : $term <=> 0;
        if ( $sign < 0 )
        {
            $term = $term->_abs();         # XXX
            $c_op = $sum_opposites{$op};
        }
        $str .= "${c_op}${term}";
    }

    $str =~ s/^\+//;

    $str;
}

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
