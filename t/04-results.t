#!perl -T

use strict;
use warnings;

use Test::More tests => 2;
use WWW::IBM::Search;

my $ibm     = WWW::IBM::Search->new();
my $content = $ibm->search_content('+perl');

ok( @{ $ibm->results($content) } >= 10, 'The result must be more than 10' );

$content = $ibm->search_content('+this_doent_exists_ok_^^');
ok( @{ $ibm->results($content) } == 0, 'The result must be 0' );
