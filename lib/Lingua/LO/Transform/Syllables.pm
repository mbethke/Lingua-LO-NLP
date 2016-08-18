package Lingua::LO::Transform::Syllables;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Class::Accessor::Fast 'antlers';

has text => (is => 'ro');

my $syllable_re = _make_regexp();
print $syllable_re;
sub new {
    my $class = shift;
    my %opts = @_;
    return bless $class->SUPER::new(\%opts), $class;
}

sub get_syllables {
    return shift->text =~ m/$syllable_re/og;
}

sub _make_regexp {
    my $x0_1 = 'ເ';
    my $x0_2 = 'ແ';
    my $x0_3 = 'ໂ';
    my $x0_4 = 'ໄ';
    my $x0_5 = 'ໃ';

    my $x1 = 'ຫ';

    my $x = '[ກຂຄງຈສຊຍດຕຖທນບປຜຝພຟມຢຣລວຫອຮໜໝ]';

    my $x2 = "[\N{U+0ebc}ຣວລ]";   # first is combining semivowel lo

    my $x3 = "[\N{U+0eb8}\x{0eb9}]";  # u and uu

    my $x4_12 = "[\N{U+0eb4}\N{U+0eb5}]";   # i and ii
    my $x4_34 = "[\N{U+0eb6}\N{U+0eb7}]";   # y and yy
    my $x4_5  = "\N{U+0ecd}";   # niggahita
    my $x4_6  = "\N{U+0eb1}";   # mai kan
    my $x4_7  = "\N{U+0ebb}";   # mai kon
    my $x4_1t4 = "[\N{U+0eb4}\N{U+0eb5}\N{U+0eb6}\N{U+0eb7}]";  # i, ii, y, yy

    my $x5 = "[\N{U+0ec8}\N{U+0ec9}\N{U+0eca}\N{U+0ecb}]";  # mai ek, tho, ti, catawa

    my $x6_1 = 'ວ';
    my $x6_2 = 'ອ';
    my $x6_3 = 'ຽ';
    my $x6 = "[${x6_1}${x6_2}${x6_3}]";

    my $x7_1 = 'ະ';
    my $x7_2 = 'າ';
    my $x7_3 = 'ຽ';
    my $x7 = "[${x7_1}${x7_2}${x7_3}";

    my $x8_3t8 = '[ຍດນມຢບ]';
    my $x8 = '[ກງຍດນມຢບວ]';

    my $x9 = '[ຈສຊພຟລ]';

    my $x10_12= '[ຯໆ]';
    my $x10_3 = "\N{U+0ecc}";   # cancellation mark

    my $x9_a_10_3 = "(?: $x9 $x10_3)";

    my $re1_all = "$x0_1 $x1? $x $x2?";
    my $re1_1 = "$re1_all $x5? $x8? $x9_a_10_3?";
    my $re1_2 = "$re1_all $x4_12 $x5? $x8? $x9_a_10_3?";
    my $re1_3 = "$re1_all $x4_34 $x5? $x6_2 $x8? $x9_a_10_3?";
    my $re1_4 = "$re1_all $x7_2 $x7_1";
    my $re1_5 = "$re1_all $x4_6 $x5? $x7_2";
    my $re1_6 = "$re1_all $x4_7 $x5? $x8  $x9_a_10_3?";
    my $re1_8 = "$re1_all $x4_7? $x5? $x6_3";
    # bug in the original paper: 1.7 == 1.6

    my $re2_all = "$x0_2 $x1? $x $x2?";
    my $re2_1 = "$re2_all $x5? $x6? $x8? $x9_a_10_3?";
    my $re2_2 = "$re2_all $x7_1";
    my $re2_3 = "$re2_all $x4_7 $x5? $x8 $x9_a_10_3?";

    my $re3_all = "$x0_3 $x1? $x $x2?";
    my $re3_1 = "$re3_all $x5? $x8? $x9_a_10_3?";
    my $re3_2 = "$re3_all $x7_1";
    my $re3_3 = "$re3_all $x4_7 $x5? $x8_3t8?";

    my $re4 = "$x0_4 $x1? $x $x2? $x5? $x6_1? $x9_a_10_3?";

    my $re5 = "$x0_5 $x1? $x $x2? $x5? $x6_1?";

    my $re6 = "$x1? $x $x2? $x3 $x5? $x8? $x9_a_10_3?";

    my $re7 = "$x1? $x $x2? $x4_1t4 $x5? $x8? $x9_a_10_3?";

    my $re8 = "$x1? $x $x2? $x4_5 $x5? $x7_2? $x9_a_10_3?";

    my $re9 = "$x1? $x $x2? $x4_6 $x5? (?: $x8 $x9_a_10_3? | $x6_1 $x7_1 )";

    my $re10= "$x1? $x $x2? $x4_7 $x5? $x6_1 $x8 $x9_a_10_3?";

    my $re11= "$x1? $x $x2? $x5? $x6 $x8 $x9_a_10_3?";

    my $re12= "$x1? $x $x2? $x5? $x7_1";

    my $re13= "$x1? $x $x2? $x5? $x7_2 $x8? $x9_a_10_3?";

    my $re14= "$x1? $x $x2? $x5? $x7_3 $x9_a_10_3?";

    my $re_num = "[໑໒໓໔໕໖໗໘໙໐]";

    my $syl = " (?:
    $re1_1 | $re1_2 | $re1_3 | $re1_4 | $re1_5 | $re1_6 | $re1_8 |
    $re2_1 | $re2_2 | $re2_3 |
    $re3_1 | $re3_2 | $re3_3 |
    $re4  | $re5  | $re6  | $re7  | $re8  | $re9  | $re10 |
    $re11 | $re12 | $re13 | $re14 | $re_num+) ";

    return qr/ ($syl) (?=$syl|\P{Lao}|\s+|$) /x;
}

