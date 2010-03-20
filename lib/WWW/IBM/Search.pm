package WWW::IBM::Search;

use strict;
use warnings;

use Carp qw/croak/;
use WWW::Mechanize;
use HTML::TreeBuilder::XPath;

our $VERSION = '0.06';

sub new {
    my $class = shift;
    my $self  = {
        where     => 'United States',
        language  => 'English',
        display   => 100,
        next_page => 0,
        how       => 'all',
        @_
    };
    return bless( $self, $class );
}

sub search {
    my ( $self, $search ) = @_;
    return [] unless $search;
    my $content = $self->search_content($search);
    my $results = $self->results($content);
    return [] unless @{$results};
    if ( $self->{'fetch_all'} == 0 ) {
        return $self->infos($results);
    } else {
        push( @{ $self->{'search'} }, @{ $self->infos($results) } );
        while ( $content = $self->next_page($content) ) {
            $results = $self->results($content);
            push( @{ $self->{'search'} }, @{ $self->infos($results) } );
        }
        return $self->{'search'};
    }
}

sub search_content {
    my ( $self, $search ) = @_;
    my $mech = WWW::Mechanize->new( timeout => 10 );
    $mech->agent_alias('Linux Mozilla');
    $mech->get(
        'http://www.ibm.com/search/?v=14&realm=ibm&cc=us&lang=en&adv.x=1&en=utfl'
    );
    croak qq{Can't get IBM $mech->status\n"} unless $mech->success;
    my %fields = (
        co   => $self->where_info( $self->{'where'} ),
        lo   => $self->language_info( $self->{'language'} ),
        hpp  => $self->{'display'},
        qt   => $self->{'how'},
        qadv => $search,
    );
    $mech->submit_form( form_number => 2, fields => \%fields );
    croak qq{Can't get IBM $mech->status\n"} unless $mech->success;
    return $mech->content;
}

sub results {
    my ( $self, $content ) = @_;
    return [] unless $content;
    my $tree = HTML::TreeBuilder::XPath->new_from_content($content);
    return [] if $tree->as_text =~ /No results were found/;
    my @results = $tree->findnodes(
        '/html/body//table[@class="ibm-results-table"]/tbody/tr');
    return \@results;
}

sub infos {
    my ( $self, $results ) = @_;
    my (@infos);
    foreach my $result ( @{$results} ) {
        push(
            @infos,
            {   title        => $self->title($result),
                uri          => $self->uri($result),
                content_text => $self->content_text($result),
                content_html => $self->content_html($result),
                html         => $self->html($result),
            }
        );
    }
    $self->delete_tree( shift @{$results} );
    return \@infos;
}

sub next_page {
    my ( $self, $content ) = @_;
    my $mech = WWW::Mechanize->new( timeout => 10 );
    $mech->agent_alias('Linux Mozilla');
    my $link = $self->next_link($content);
    $link ? $mech->get($link) : return undef;
    return undef unless $mech->success;
    return $mech->content;
}

sub next_link {
    my ( $self, $content ) = @_;
    my $tree = HTML::TreeBuilder::XPath->new_from_content($content);
    my $link
        = $tree->findnodes('//span[@class="ibm-table-navigation-links"]/a')
        ->[-1];

    # - If the page don't have pagination return undef
    return undef unless $link;

    if ( $link->as_text !~ /Next/ || !$link->attr('href') ) {
        $tree->delete;
        return undef;
    }
    my $link_ok = $link->attr('href');
    $tree->delete;
    return $link_ok;
}

sub title {
    my ( $self, $result ) = @_;
    return $result->findvalue('.//a[@class="ibm-feature-link"]');
}

sub uri {
    my ( $self, $result ) = @_;
    return $result->findnodes('.//a')->[0]->attr('href');
}

sub content_text {
    my ( $self, $result ) = @_;
    return $result->findnodes('.//td')->[0]->as_text;
}

sub content_html {
    my ( $self, $result ) = @_;
    return $result->findnodes('.//td')->[0]->as_HTML;
}

sub html {
    my ( $self, $result ) = @_;
    return $result->as_HTML;
}

sub delete_tree {
    my ( $self, $tree ) = @_;
    $tree->delete;
    return 73802;
}

sub where_info {
    my ( $self, $where ) = @_;
    return undef unless $where;
    my %ibms = (
        'Worldwide'                        => '',
        'Anguilla'                         => 'ai',
        'Antigua and Barbuda'              => 'ag',
        'Argentina'                        => 'ar',
        'Aruba'                            => 'aw',
        'Australia'                        => 'au',
        'Austria'                          => 'at',
        'Bahamas'                          => 'bs',
        'Bahrain'                          => 'bh',
        'Bangladesh'                       => 'bd',
        'Barbados'                         => 'bb',
        'Belgium'                          => 'be',
        'Bermuda'                          => 'bm',
        'Bolivia'                          => 'bo',
        'Brazil'                           => 'br',
        'Bulgaria'                         => 'bg',
        'Canada'                           => 'ca',
        'Cayman Islands'                   => 'ky',
        'Chile'                            => 'cl',
        'China'                            => 'cn',
        'Colombia'                         => 'co',
        'Croatia'                          => 'hr',
        'Cyprus'                           => 'cy',
        'Czech Republic'                   => 'cz',
        'Denmark'                          => 'dk',
        'Dominica'                         => 'dm',
        'Ecuador'                          => 'ec',
        'Egypt'                            => 'eg',
        'Estonia'                          => 'ee',
        'Finland'                          => 'fi',
        'France'                           => 'fr',
        'Germany'                          => 'de',
        'Greece'                           => 'gr',
        'Grenada'                          => 'gd',
        'Guyana'                           => 'gy',
        'Hong Kong'                        => 'hk',
        'Hungary'                          => 'hu',
        'India'                            => 'in',
        'Indonesia'                        => 'id',
        'Ireland'                          => 'ie',
        'Israel'                           => 'il',
        'Italy'                            => 'it',
        'Jamaica'                          => 'jm',
        'Japan'                            => 'jp',
        'Jordan'                           => 'jo',
        'Korea, Republic of'               => 'kr',
        'Kuwait'                           => 'kw',
        'Latvia'                           => 'lv',
        'Lebanon'                          => 'lb',
        'Lithuania'                        => 'lt',
        'Malaysia'                         => 'my',
        'Mexico'                           => 'mx',
        'Montserrat'                       => 'ms',
        'Netherlands Antilles'             => 'an',
        'Netherlands'                      => 'nl',
        'New Zealand'                      => 'nz',
        'Norway'                           => 'no',
        'Oman'                             => 'om',
        'Pakistan'                         => 'pk',
        'Paraguay'                         => 'py',
        'Peru'                             => 'pe',
        'Philippines'                      => 'ph',
        'Poland'                           => 'pl',
        'Portugal'                         => 'pt',
        'Qatar'                            => 'qa',
        'Romania'                          => 'ro',
        'Russian Federation'               => 'ru',
        'Saint Kitts and Nevis'            => 'kn',
        'Saint Lucia'                      => 'lc',
        'Saint Vincent and the Grenadines' => 'vc',
        'Saudi Arabia'                     => 'sa',
        'Serbia'                           => 'rs',
        'Singapore'                        => 'sg',
        'Slovakia'                         => 'sk',
        'Slovenia'                         => 'si',
        'South Africa'                     => 'za',
        'Spain'                            => 'es',
        'Sri Lanka'                        => 'lk',
        'Suriname'                         => 'sr',
        'Sweden'                           => 'se',
        'Switzerland'                      => 'ch',
        'Taiwan'                           => 'tw',
        'Thailand'                         => 'th',
        'Trinidad and Tobago'              => 'tt',
        'Turkey'                           => 'tr',
        'Turks and Caicos Islands'         => 'tc',
        'Ukraine'                          => 'ua',
        'United Arab Emirates'             => 'ae',
        'United Kingdom'                   => 'gb',
        'United States'                    => 'us',
        'Uruguay'                          => 'uy',
        'Venezuela'                        => 've',
        'Viet Nam'                         => 'vn',
        'Virgin Islands, British'          => 'vg',

    );
    return $ibms{$where};
}

sub language_info {
    my ( $self, $language ) = @_;
    return undef unless $language;
    my %languages = (
        'Any'        => '',
        'Bulgarian'  => 'bg',
        'ChineseS'   => 'zh-simplified',
        'ChineseT'   => 'zh-traditional',
        'Croatian'   => 'hr',
        'Czech'      => 'cs',
        'Danish'     => 'da',
        'Dutch'      => 'nl',
        'English'    => 'en',
        'Estonian'   => 'et',
        'Finnish'    => 'fi',
        'French'     => 'fr',
        'German'     => 'de',
        'Greek'      => 'el',
        'Hebrew'     => 'he',
        'Hungarian'  => 'hu',
        'Italian'    => 'it',
        'Japanese'   => 'ja',
        'Korean'     => 'ko',
        'Latvian'    => 'lv',
        'Lithuanian' => 'lt',
        'Norwegian'  => 'no',
        'Polish'     => 'pl',
        'Portuguese' => 'pt',
        'Romanian'   => 'ro',
        'Russian'    => 'ru',
        'Slovak'     => 'sk',
        'Slovenian'  => 'sl',
        'Spanish'    => 'es',
        'Swedish'    => 'sv',
        'Turkish'    => 'tr',
        'Ukrainian'  => 'uk',
    );
    return $languages{$language};
}

return 73802

__END__

=head1 NAME

WWW::IBM::Search - API to IBM Search

=head1 SYNOPSIS

WWW::IBM::Search is an API to L<http://www.ibm.com/search/?v=14&realm=ibm&cc=us&lang=en&adv.x=1&en=utf&q=foo>

    use WWW::IBM::Search;

    my $ibm = WWW::IBM::Search->new(
		where		=>	'United States',
		language	=>	'English',
		display		=>	25,
	;
    my $results = $ibm->search('+perl +developerworks');
    foreach my $result (@{ $results }) {
    	print $result->{'title'},"\t", print $result->{'uri'},"\n";
    }
    ...

=head1 METHODS

=head2 new

Returns a new WWW::IBM::Search search object.
Here are the parameters:

=over 5

=item * where => 'country' (default is 'United States')

You can specify in which IBM the search will be performed. The following IBMs are available:

	Worldwide
	Anguilla
	Antigua and Barbuda
	Argentina
	Aruba
	Australia
	Austria
	Bahamas
	Bahrain
	Bangladesh
	Barbados
	Belgium
	Bermuda
	Bolivia
	Brazil
	British
	Bulgaria
	Canada
	Cayman Islands
	Chile
	China
	Colombia
	Croatia
	Cyprus
	Czech Republic
	Denmark
	Dominica
	Ecuador
	Egypt
	Estonia
	Finland
	France
	Germany
	Greece
	Grenada
	Guyana
	Hong Kong
	Hungary
	India
	Indonesia
	Ireland
	Israel
	Italy
	Jamaica
	Japan
	Jordan
	Korea, Republic of
	Kuwait
	Latvia
	Lebanon
	Lithuania
	Malaysia
	Mexico
	Montserrat
	Netherlands
	Netherlands Antilles
	New Zealand
	Norway
	Oman
	Pakistan
	Paraguay
	Peru
	Philippines
	Poland
	Portugal
	Qatar
	Romania
	Russian Federation
	Saint Kitts and Nevis
	Saint Lucia
	Saint Vincent and the Grenadines
	Saudi Arabia
	Serbia
	Singapore
	Slovakia
	Slovenia
	South Africa
	Spain
	Sri Lanka
	Suriname
	Sweden
	Switzerland
	Taiwan
	Thailand
	Trinidad and Tobago
	Turkey
	Turks and Caicos Islands
	Ukraine
	United Arab Emirates
	United Kingdom
	United States
	Uruguay
	Venezuela
	Viet Nam
	Virgin Islands


=item * language => "language"  (default is 'English')

Your language:

	Any
	Bulgarian
	ChineseS (simplified)
	ChineseT (traditional)
	Croatian
	Czech
	Danish
	Dutch
	English
	Estonian
	Finnish
	French
	German
	Greek
	Hebrew
	Hungarian
	Italian
	Japanese
	Korean
	Latvian
	Lithuanian
	Norwegian
	Polish
	Portuguese
	Romanian
	Russian
	Slovak
	Slovenian
	Spanish
	Swedish
	Turkish
	Ukrainian


=item * display => number (default is 100)

The number of results per page:

	10
	25
	50
	75
	100

=item * fetch_all => [0|1] (default is 0)

Traverses all the result's pages before returning.

=item * how => "how" (default is 'all of the words')

	all
	any
	phrase

=back

=head2 search

Before you search, please read the documentaion L<http://www.ibm.com/search/help/us/en/#improve>

Pass the string to search, and, this function will return an array ref, where each element is a result hash (see below).

    my $results = $ibm->search('+perl +developerworks');

    foreach my $result (@{ $results }) {
        say $result->{'title'};
        say $result->{'uri'};
        say $result->{'content_text'};
    }

The attributes below show the information available to you on each query.

=head2 title

    print $result->{'title'}

The title name from result.

=head2 uri

    print $result->{'uri'}

The uri from result.

=head2 content_text

    print $result->{'content_text'}

The content as text from result.

=head2 content_html

    print $result->{'content_html'}

The content as HTML from result.

=head2 html

    print $result->{'html'}

The literal HTML from result.

=head1 AUTHOR

Daniel de Oliveira Mantovani, C<< <daniel.oliveira.mantovani at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-ibm at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-IBM-Search>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::IBM::Search


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-IBM-Search>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-IBM-Search>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-IBM-Search>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-IBM-Search/>

=back


=head1 ACKNOWLEDGEMENTS

Breno G. Oliveira   <garu>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Daniel de Oliveira Mantovani.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

