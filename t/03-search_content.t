#!perl -T

use strict;
use warnings;

use Test::More tests => 8;
use WWW::IBM::Search;

my $ibm = WWW::IBM::Search->new();

like( $ibm->search_content('+perl'), qr/Perl developers/, 'This search return the expected[0]' );
unlike( $ibm->search_content('+perl'), qr/No results were found/, 'This search found something[0]' );

like( $ibm->search_content('+perl +developerworks'), qr/developerworks/, 'This search return the expected[1]' );
unlike( $ibm->search_content('+perl +developerworks'), qr/No results were found/, 'This search found something[1]' );

$ibm = WWW::IBM::Search->new( where => 'Worldwide', language => 'Portuguese' );

like( $ibm->search_content('+perl'), qr/Brasil/, 'This search return the expected[3]' );
unlike( $ibm->search_content('+perl'), qr/No results were found/, 'This search found something[3]' );

$ibm = WWW::IBM::Search->new( where => 'Worldwide', language => 'Portuguese', how => 'any of the words' );

like( $ibm->search_content('+perl'), qr/Brasil/, 'This search return the expected[3]' );
unlike( $ibm->search_content('+perl'), qr/No results were found/, 'This search found something[3]' );
