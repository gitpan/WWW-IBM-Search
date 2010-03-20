#!perl -T

use strict;
use warnings;

use Test::More tests => 51;
use WWW::IBM::Search;

my $ibm     = WWW::IBM::Search->new(display => 10);
my $results = $ibm->results( $ibm->search_content('+perl') );

ok( $results, 'Results OK' );

my $infos = $ibm->infos($results);

foreach my $info ( @{$infos} ) {

    like( $info->{'title'},        qr/\w+/,                  'Title' );
    like( $info->{'uri'},          qr{http://www\.ibm\.com}, 'URI' );
    like( $info->{'content_text'}, qr/\w+/,                  'Content text ' );
    like( $info->{'content_html'}, qr/[<>]{2,}/,             'Content HTML' );
    like( $info->{'html'},         qr/[<>]{2,}/,             'Pure HTML' );

}
