use strict;
use warnings;
use ExtUtils::MakeMaker;

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
        'WWW::Mechanize'           => 0,
        'HTML::TreeBuilder::XPath' => 0,
        'Carp'                     => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'WWW-IBM-Search-*' },
);
