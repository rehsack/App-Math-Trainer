package App::Math::Trainer::Role::Exercise;

use warnings;
use strict;

use Moo::Role;
use MooX::Options;

option amount => (
                   is      => "ro",
                   doc     => "specifies amount of calculations to generate",
                   format  => "i",
                   short   => "n",
                   default => sub { 25 },
                 );

1;
