use strict;
use warnings;

use ExtUtils::MakeMaker;
use File::Spec;

my @tests = glob File::Spec->catfile( 't', '*.t' );

WriteMakefile(
    NAME => 'WWW::IBM::Search',
    AUTHOR =>
        q{Daniel de Oliveira Mantovani <daniel.oliveira.mantovani@gmail.com>},
    VERSION_FROM  => 'lib/WWW/IBM/Search.pm',
    ABSTRACT_FROM => 'lib/WWW/IBM/Search.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'               => 0,
        'WWW::Mechanize'           => '1.60',
        'HTML::TreeBuilder::XPath' => '0.11',
        'Carp'                     => 0,
    },
    test => { TESTS => join( ' ', @tests ) },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'WWW-IBM-Search-*' },
);
