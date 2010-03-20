#!perl -T

use strict;
use warnings;

use Test::More tests => 6;
use WWW::IBM::Search;

eval { require WWW::Mechanize };

SKIP: {
    skip "You need WWW::Mechanize", 6 if $@;
    my $mech = WWW::Mechanize->new();

    # - Has next page

    $mech->get('http://www.ibm.com/Search/?q=%2Bnasa&v=16&en=utf&lang=en&cc=us&Search=Search');
    die $mech->status unless $mech->success;
    my $has = $mech->content;

    # - No has next page
    $mech->get(
'http://www.ibm.com/search/?en=utf&s=adv&lang=en&cc=us&qadv=%2Bstupid&qt=all&co=us&lo=en&hpp=100&ibm-submit=Submit+Query'
    );

    # - Has previus here
    $mech->get(
        'http://www.ibm.com/search/?lv=c&o=90&en=utf&v=16&lang=en&cc=us&q=%2Bperl&ibm-go.x=0&ibm-go.y=0&ibm-go=Go&lv=c'
    );
    die $mech->status unless $mech->success;
    my $previus_has = $mech->content;

    die $mech->status unless $mech->success;
    my $no_has = $mech->content;

    # - Start object

    my $ibm = WWW::IBM::Search->new();

    like(
        $ibm->next_link($has),
        qr{http://www\.ibm\.com/search\?lv=c&o=10&q=%2Bnasa&v=16&en=utf&lang=en&cc=us&Search=Search},
        'Return this link here [0]'
    );
    isnt( $ibm->next_link($no_has),      'something', 'Return undef here [0]' );
    isnt( $ibm->next_link($previus_has), 'something', 'Return undef here [1]' );

    ok( $ibm->next_link($has), 'Return Something [0]' );
    isnt( $ibm->next_link($no_has),      '', 'Return undef here [0]' );
    isnt( $ibm->next_link($previus_has), '', 'Return undef here [1]' );
}
