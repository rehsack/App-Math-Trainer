package App::Math::Trainer::Cmd::Frac;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer::Cmd::Frac - namespace for fraction exercises

=cut

our $VERSION = '0.001';

use Moo;
use MooX::Cmd;
use MooX::Options;

*execute = sub {
    shift->option_usage();
};

1;
