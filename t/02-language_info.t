#!perl -T

use strict;
use warnings;

use Test::More tests => 6;
use WWW::IBM::Search;

my $ibm = WWW::IBM::Search->new();

is( $ibm->language_info('English'), 'en', 'Language [0] expected' );
isnt( $ibm->language_info('English'), 'br', 'Language [0] not expected' );
is( $ibm->language_info('Portuguese'), 'pt', 'Language [1] expected' );
isnt( $ibm->language_info('Portuguese'), 'ru', 'Language [1] not expected' );
is( $ibm->language_info('Any'), '', 'Language [2] expected' );
unlike( $ibm->language_info('Any'), qr/.+/, 'Language [2] expected' );
