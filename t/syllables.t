#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open ':encoding(UTF-8)', ':std';
use Test::More;
use charnames qw/ :full lao /;
use Unicode::Normalize qw/ reorder NFD /;
use Lingua::LO::Transform::Syllables;
use Data::Dumper;

my %tests = (
    ""          => [],
    ສະບາຍດີ      => [ qw/ ສະ ບາຍ ດີ / ],
    ກວ່າດອກ      => [ qw/ ກວ່າ ດອກ /],
    ເພື່ອນ        => [ qw/ ເພື່ອນ / ],
    # ຜູ້ເຂົ້າ        => [ qw/ ຜູ້ ເຂົ້າ /],    # drop invalid second syllable
    "\N{LAO LETTER PHO SUNG}\N{LAO VOWEL SIGN UU}\N{LAO TONE MAI THO}\N{LAO VOWEL SIGN E}\N{LAO LETTER KHO SUNG}\N{LAO VOWEL SIGN I}\N{LAO TONE MAI THO}\N{LAO VOWEL SIGN AA}"
    => [ "\N{LAO LETTER PHO SUNG}\N{LAO VOWEL SIGN UU}\N{LAO TONE MAI THO}" ],
    "\N{LAO LETTER PHO SUNG}\N{LAO VOWEL SIGN UU}\N{LAO TONE MAI THO}\N{ZERO WIDTH SPACE}\N{LAO VOWEL SIGN E}\N{LAO LETTER KHO SUNG}\N{LAO VOWEL SIGN I}\N{LAO TONE MAI THO}\N{LAO VOWEL SIGN AA}"
    => [ "\N{LAO LETTER PHO SUNG}\N{LAO VOWEL SIGN UU}\N{LAO TONE MAI THO}" ],
    ກວ່າດອກ໐໑໒໓  => [qw/ ກວ່າ ດອກ ໐໑໒໓ /],
    ຄຳດີ         => [qw/ ຄຳ ດີ /],   # composed sala am
    ຄໍາດີ         => [qw/ ຄໍາ ດີ /],   # decomposed sala am
    ຄໍາູດີ         => [qw/ ດີ /],      # malformed first syllable "khamu" dropped
    ກັ           => [ ],
    ກັນ          => [qw/ ກັນ / ],
    ກັວນ         => [qw/ ກັວນ / ],
    ກົ           => [ ],
    ກົດ          => [qw/ ກົດ / ],
    ກັອກ         => [ ],
    ແປຽ         => [qw/ ແປຽ / ],
    ເກັາະ        => [ ],
    ມື້ນີ້          => [qw/ ມື້ ນີ້ /],
    'ມະນຸດທຸກຄົນເກີດມາມີກຽດສັກສີ/ສິດທິ/ເສຣີພາບແລະຄວາມສເມີພາບເທົ່າທຽມກັນ. ທຸກໆຄົນມີເຫດຜົນແລະຄວາມຄິດຄວາມເຫັນສ່ວນຕົວຂອງໃຜຂອງມັນ/ແຕ່ວ່າມະນຸດທຸກໆຄົນຄວນປະພຶດຕໍ່ກັນຄືກັນກັບເປັນອ້າຍນ້ອງກັນ' => [ qw/ ມະ ນຸດ ທຸກ ຄົນ ເກີດ ມາ ມີ ກຽດ ສັກ ສີ ສິດ ທິ ເສຣີ ພາບ ແລະ ເມີ ພາບ ເທົ່າ ທຽມ ກັນ ທຸກໆ ຄົນ ມີ ເຫດ ຜົນ ແລະ ຄວາມ ຄິດ ຄວາມ ເຫັນ ສ່ວນ ຕົວ ຂອງ ໃຜ ຂອງ ມັນ ແຕ່ ວ່າ ມະ ນຸດ ທຸກໆ ຄົນ ຄວນ ປະ ພຶດ ຕໍ່ ກັນ ຄື ກັນ ກັບ ເປັນ ອ້າຍ ນ້ອງ ກັນ /],
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
    unless( is_deeply($syl, $tests{$text}, "`$text' split correctly") ) {
        warn "Wanted: " . dump_unicode_list(@{$tests{$text}}) .
        "\nFound : " . dump_unicode_list(@$syl) .
        "\nText:   " . dump_unicode($text) . sprintf('(%s)', $text). 
        "\nNormal: " . dump_unicode(reorder(NFD($text))) . sprintf('(%s)' ,reorder(NFD($text))) .
        "\n";
    }
}

is_deeply(
    [ Lingua::LO::Transform::Syllables->new(text => 'bla ສະບາຍ ດີ foo ດີ bar baz')->get_fragments ],
    [
        { text => 'bla ', is_lao => '' },
        { text => 'ສະ', is_lao => 1 },
        { text => 'ບາຍ', is_lao => 1 },
        { text => ' ', is_lao => '' },
        { text => 'ດີ', is_lao => 1 },
        { text => ' foo ', is_lao => '' },
        { text => 'ດີ', is_lao => 1 },
        { text => ' bar baz', is_lao => '' },
    ],
    "get_fragments() segments mixed Lao/other text"
);
is_deeply(
    [ Lingua::LO::Transform::Syllables->new(text => "bla\nfoo ສະບາຍດີ\nbazດີ ເພື່ອນ")->get_fragments ],
    [
        { text => "bla\nfoo ", is_lao => '' },
        { text => "ສະ", is_lao => 1 },
        { text => "ບາຍ", is_lao => 1 },
        { text => "ດີ", is_lao => 1 },
        { text => "\nbaz", is_lao => '' },
        { text => "ດີ", is_lao => 1 },
        { text => " ", is_lao => '' },
        { text => "ເພື່ອນ", is_lao => 1 },
    ],
    "get_fragments() segments mixed text with newlines"
);
is_deeply(
    [ Lingua::LO::Transform::Syllables->new(text => "ບ່ອນ​ຈອດ​ລົດ")->get_fragments ],
    [
        { text => "ບ່ອນ", is_lao => 1 },
        { text => "ຈອດ", is_lao => 1 },
        { text => "ລົດ", is_lao => 1 },
    ],
    "get_fragments() ignores embedded ZERO WIDTH SPACE"
);

done_testing;

