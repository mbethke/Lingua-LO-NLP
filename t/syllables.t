#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open ':encoding(UTF-8)', ':std';
use Test::More;
use Unicode::Normalize qw/ reorder NFD /;
use Lingua::LO::Transform::Syllables;

my %tests = (
    ""          => [],
    ສະບາຍດີ      => [ qw/ ສະ ບາຍ ດີ / ],
    ກວ່າດອກ      => [ qw/ ກວ່າ ດອກ /],

    # ຜູ້ເຂົ້າ        => [ qw/ ຜູ້ ເຂົ້າ /],
    "\N{U+0e9c}\N{U+0eb9}\N{U+0ec9}\N{U+0ec0}\N{U+0e82}\N{U+0eb4}\N{U+0ec9}\N{U+0eb2}"
    => [ "\N{U+0e9c}\N{U+0eb9}\N{U+0ec9}", "\N{U+0ec0}\N{U+0e82}\N{U+0eb4}\N{U+0ec9}\N{U+0eb2}" ],
    "\N{U+0e9c}\N{U+0eb9}\N{U+0ec9}\N{U+200b}\N{U+0ec0}\N{U+0e82}\N{U+0eb4}\N{U+0ec9}\N{U+0eb2}"
    => [ "\N{U+0e9c}\N{U+0eb9}\N{U+0ec9}", "\N{U+0ec0}\N{U+0e82}\N{U+0eb4}\N{U+0ec9}\N{U+0eb2}" ],
    ກວ່າດອກ໐໑໒໓  => [ qw/ ກວ່າ ດອກ ໐໑໒໓ /],
    ຄຳດີ         => [ qw/ ຄຳ ດີ /],   # composed sala am
    ຄໍາດີ         => [ qw/ ຄໍາ ດີ /],   # decomposed sala am
    ຄໍາູດີ         => [ qw/ ດີ /],      # malformed first syllable "khamu" dropped
);

sub dump_unicode {
    my $s = shift;
    return sprintf(q["%s"], join(" ", map { sprintf("%03x", ord) } split //, $s));
}

sub dump_unicode_list {
    return sprintf('[ %s ]', join(", ", map { dump_unicode($_) } @_));
}

my $o = Lingua::LO::Transform::Syllables->new(text => 'ສະບາຍດີ');
isa_ok($o, 'Lingua::LO::Transform::Syllables');

for my $text (sort keys %tests) {
    $o = Lingua::LO::Transform::Syllables->new(text => $text);
    my $syl = [ $o->get_syllables ];
    #use Data::Dumper; print Dumper($syl);
    unless( is_deeply($syl, $tests{$text}, "`$text' split correctly") ) {
        warn "Wanted: " . dump_unicode_list(@{$tests{$text}}) .
        "\nFound : " . dump_unicode_list(@$syl) .
        "\nText:   " . dump_unicode($text) . sprintf('(%s)', $text). 
        "\nNormal: " . dump_unicode(reorder(NFD($text))) . sprintf('(%s)' ,reorder(NFD($text))) .
        "\n";
    }
}
done_testing;

