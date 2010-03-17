#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::IBM::Search' ) || print "Bail out!
";
}

diag( "Testing WWW::IBM::Search $WWW::IBM::Search::VERSION, Perl $], $^X" );
