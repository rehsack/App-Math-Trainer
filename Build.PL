use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::Math::Trainer',
    license             => 'perl',
    dist_author         => q{Jens Rehsack <rehsack@cpan.org>},
    dist_version_from   => 'lib/App/Math/Trainer.pm',
    build_requires => {
	'App::Cmd::Tester' => '0.300',
        'Test::More' => '0.90',
    },
    requires => {
	'App::Cmd' => '0.300',
	'Carp' => 0,
	'LaTeX::Table' => '1.0.6',
	'Template' => '2.00',
	'Template::Plugin::Latex' => '3.01',
    },
    share_dir          => { dist => [ 'share', ], },
    add_to_cleanup      => [ 'App-Math-Trainer-*' ],
);

$builder->create_build_script();
