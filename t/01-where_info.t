#!perl -T

use strict;
use warnings;

use Test::More tests => 6;
use WWW::IBM::Search;

my $ibm = WWW::IBM::Search->new();

is( $ibm->where_info('Brazil'), 'br', 'Where [0] expected' );
isnt( $ibm->where_info('Brazil'), 'en', 'Where [0] not expected' );
is( $ibm->where_info('United States'), 'us', 'Where [1] expected' );
isnt( $ibm->where_info('United States'), 'jp', 'Where [1] not expected]' );
is( $ibm->where_info('Worldwide'), '', 'Where [2] expected' );
unlike( $ibm->where_info('Worldwide'), qr/.+/, 'Where [2] expected' );
