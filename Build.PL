use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
                                  module_name       => 'App::Math::Tutor',
                                  license           => 'perl',
                                  dist_author       => q{Jens Rehsack <rehsack@cpan.org>},
                                  dist_version_from => 'lib/App/Math/Tutor.pm',
                                  build_requires    => {
                                                      'MooX::Cmd::Tester' => '0.007',
                                                      'Test::More'        => '0.90',
                                                    },
                                  requires => {
                                                'Carp'                    => 0,
                                                'LaTeX::Table'            => '1.0.6',
                                                'Hash::MoreUtils'         => 0,
                                                'Math::Complex'           => '1.56',
                                                'Math::Prime::Util'       => 0,
                                                'Module::Runtime'         => 0,
                                                'MooX::Cmd'               => '0.007',
                                                'MooX::Options'           => '4.000',
                                                'Template'                => '2.25',
                                                'Template::Plugin::Latex' => '3.01',
                                              },
                                  share_dir => {
                                                 dist => [ 'share', ],
                                               },
                                  add_to_cleanup => ['App-Math-Tutor-*'],
                                  meta_merge     => {
                                       'meta-spec' => { version => 2 },
                                       resources   => {
                                           repository => {
                                               url => 'git://github.com/rehsack/App-Math-Tutor.git',
                                               web => 'https://github.com/rehsack/App-Math-Tutor',
                                               type => 'git',
                                           },
                                       },
                                       prereqs => {
                                                 develop => {
                                                     requires => {
                                                         'Test::CPAN::Changes'                 => 0,
                                                         'Test::CheckManifest'                 => 0,
                                                         'Test::Pod'                           => 0,
                                                         'Test::Pod::Coverage'                 => 0,
                                                         'Test::Pod::Spelling::CommonMistakes' => 0,
                                                     },
                                                 },
                                       },
                                  },
                                  create_readme => 1,
                                  test_files    => join( ' ' => 't/*.t xt/*.t' ),
                                );

$builder->create_build_script();
