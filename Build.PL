use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Archive::Simple',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/Archive/Simple.pm',
    requires          => {
        'perl'             => 5.008,
    },
    configure_requires => {
        'Module::Build' => 0.38,
    },
    build_requires => {
        'Test::More'       => 0,
        'Test::NoWarnings' => 0,
    },
    add_to_cleanup     => [ 'Archive-Simple-*' ],
    create_makefile_pl => 'traditional',
    create_license     => 1,
    meta_merge => {
        resources => {
            repository => 'git://github.com/ivanwills/Archive-Simple.git',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Archive::Simple',
        },
    },
);

$builder->create_build_script();
