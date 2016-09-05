package Lingua::LO::Transform::Regexp;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1');
use charnames qw/ :full lao /;

sub syllable_short {
    my $x0_1 = 'ເ';
    my $x0_2 = 'ແ';
    my $x0_3 = 'ໂ';
    my $x0_4 = 'ໄ';
    my $x0_5 = 'ໃ';

    my $x1 = 'ຫ';

    my $x = '[ກຂຄງຈສຊຍດຕຖທນບປຜຝພຟມຢຣລວຫອຮໜໝ]';

    my $x2 = "[\N{LAO SEMIVOWEL SIGN LO}ຣວລ]";

    my $x3 = "[\N{LAO VOWEL SIGN U}\N{LAO VOWEL SIGN UU}]";

    my $x4_12 = "[\N{LAO VOWEL SIGN I}\N{LAO VOWEL SIGN II}]";
    my $x4_34 = "[\N{LAO VOWEL SIGN Y}\N{LAO VOWEL SIGN YY}]";
    my $x4_5  = "\N{LAO NIGGAHITA}";
    my $x4_6  = "\N{LAO VOWEL SIGN MAI KAN}";
    my $x4_7  = "\N{LAO VOWEL SIGN MAI KON}";
    my $x4_1t4 = "[\N{LAO VOWEL SIGN I}\N{LAO VOWEL SIGN II}\N{LAO VOWEL SIGN Y}\N{LAO VOWEL SIGN YY}]";

    my $x5 = "[\N{LAO TONE MAI EK}\N{LAO TONE MAI THO}\N{LAO TONE MAI TI}\N{LAO TONE MAI CATAWA}]";

    my $x6_1 = 'ວ';
    my $x6_2 = 'ອ';
    my $x6_3 = 'ຽ';
    my $x6 = "[${x6_1}${x6_2}${x6_3}]";

    my $x7_1 = 'ະ';
    my $x7_2 = 'າ';
    my $x7_3 = "\N{LAO VOWEL SIGN AM}";
    # Is this necessary? Seems not.
    # my $x7_3 = '(?: \N{LAO NIGGAHITA}\N{LAO VOWEL SIGN AA} | \N{LAO VOWEL SIGN AM})';

    my $x8_3t8 = '[ຍດນມຢບ]';
    my $x8 = '[ກງຍດນມຢບວ]';

    my $x9 = '[ຈສຊພຟລ]';

    my $x10_12= '[ຯໆ]';
    my $x10_3 = "\N{LAO CANCELLATION MARK}";

    my $x9_a_10_3 = "(?: $x9 $x10_3)";

    my $re1_all = "$x0_1 $x1? $x $x2?";
    my $re1_1 = "$x5? $x8? $x9_a_10_3?";
    my $re1_2 = "$x4_12 $x5? $x8? $x9_a_10_3?";
    my $re1_3 = "$x4_34 $x5? $x6_2 $x8? $x9_a_10_3?";
    my $re1_4 = "$x7_2 $x7_1";
    my $re1_5 = "$x4_6 $x5? $x7_2";
    my $re1_6 = "$x4_7 $x5? $x8  $x9_a_10_3?";
    my $re1_8 = "$x4_7? $x5? $x6_3";
    # bug in the original paper: 1.7 == 1.6

    my $re2_all = "$x0_2 $x1? $x $x2?";
    my $re2_1 = "$x5? $x6? $x8? $x9_a_10_3?";
    my $re2_2 = "$x7_1";
    my $re2_3 = "$x4_7 $x5? $x8 $x9_a_10_3?";

    my $re3_all = "$x0_3 $x1? $x $x2?";
    my $re3_1 = "$x5? $x8? $x9_a_10_3?";
    my $re3_2 = "$x7_1";
    my $re3_3 = "$x4_7 $x5? $x8_3t8?";

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

    my $syl = "(?: (?:
    (?: $re1_all (?: $re1_1 | $re1_2 | $re1_3 | $re1_4 | $re1_5 | $re1_6 | $re1_8 ) ) |
    (?: $re2_all (?: $re2_1 | $re2_2 | $re2_3 ) ) |
    (?: $re3_all (?: $re3_1 | $re3_2 | $re3_3 ) ) |
    $re4  | $re5  | $re6  | $re7  | $re8  | $re9  | $re10 |
    $re11 | $re12 | $re13 | $re14 ) $x10_12? | $re_num+)";

    #print "$syl\n";
    #print "\\G($syl | .+?(?=$syl|\$) )\n";

    return qr/ $syl /x;
}

sub syllable_named {
    my %e = (
        x0_1 => 'ເ',
        x0_2 => 'ແ',
        x0_3 => 'ໂ',
        x0_4 => 'ໄ',
        x0_5 => 'ໃ',

        x1 => 'ຫ',

        x => '[ກຂຄງຈສຊຍດຕຖທນບປຜຝພຟມຢຣລວຫອຮໜໝ]',

        x2 => "[\N{LAO SEMIVOWEL SIGN LO}ຣວລ]",

        x3 => "[\N{LAO VOWEL SIGN U}\N{LAO VOWEL SIGN UU}]",

        x4_12 => "[\N{LAO VOWEL SIGN I}\N{LAO VOWEL SIGN II}]",
        x4_34 => "[\N{LAO VOWEL SIGN Y}\N{LAO VOWEL SIGN YY}]",
        x4_5  => "\N{LAO NIGGAHITA}",
        x4_6  => "\N{LAO VOWEL SIGN MAI KAN}",
        x4_7  => "\N{LAO VOWEL SIGN MAI KON}",
        x4_1t4 => "[\N{LAO VOWEL SIGN I}\N{LAO VOWEL SIGN II}\N{LAO VOWEL SIGN Y}\N{LAO VOWEL SIGN YY}]",

        x5 => "[\N{LAO TONE MAI EK}\N{LAO TONE MAI THO}\N{LAO TONE MAI TI}\N{LAO TONE MAI CATAWA}]",

        x6_1 => 'ວ',
        x6_2 => 'ອ',
        x6_3 => 'ຽ',
        x6 => '[$x6_1$x6_2$x6_3]',

        x7_1 => 'ະ',
        x7_2 => 'າ',
        x7_3 => "\N{LAO VOWEL SIGN AM}",

        x8_3t8 => '[ຍດນມຢບ]',
        x8 => '[ກງຍດນມຢບວ]',

        x9 => '[ຈສຊພຟລ]',

        x10_12=> '[ຯໆ]',
        x10_3 => "\N{LAO CANCELLATION MARK}",

        x9a10_3 => '(?: $x9 $x10_3)',

        re1_all => '$x0_1 $x1? $x $x2?',
        re1_1 => '$x5? $x8? $x9a10_3?',
        re1_2 => '$x4_12 $x5? $x8? $x9a10_3?',
        re1_3 => '$x4_34 $x5? $x6_2 $x8? $x9a10_3?',
        re1_4 => '$x7_2 $x7_1',
        re1_5 => '$x4_6 $x5? $x7_2',
        re1_6 => '$x4_7 $x5? $x8  $x9a10_3?',
        re1_8 => '$x4_7? $x5? $x6_3',

        re2_all => '$x0_2 $x1? $x $x2?',
        re2_1 => '$x5? $x6? $x8? $x9a10_3?',
        re2_2 => '$x7_1',
        re2_3 => '$x4_7 $x5? $x8 $x9a10_3?',

        re3_all => '$x0_3 $x1? $x $x2?',
        re3_1 => '$x5? $x8? $x9a10_3?',
        re3_2 => '$x7_1',
        re3_3 => '$x4_7 $x5? $x8_3t8?',

        re4 => '$x0_4 $x1? $x $x2? $x5? $x6_1? $x9a10_3?',

        re5 => '$x0_5 $x1? $x $x2? $x5? $x6_1?',

        re6 => '$x1? $x $x2? $x3 $x5? $x8? $x9a10_3?',

        re7 => '$x1? $x $x2? $x4_1t4 $x5? $x8? $x9a10_3?',

        re8 => '$x1? $x $x2? $x4_5 $x5? $x7_2? $x9a10_3?',

        re9 => '$x1? $x $x2? $x4_6 $x5? (?: $x8 $x9a10_3? | $x6_1 $x7_1 )',

        re10=> '$x1? $x $x2? $x4_7 $x5? $x6_1 $x8 $x9a10_3?',

        re11=> '$x1? $x $x2? $x5? $x6 $x8 $x9a10_3?',

        re12=> '$x1? $x $x2? $x5? $x7_1',

        re13=> '$x1? $x $x2? $x5? $x7_2 $x8? $x9a10_3?',

        re14=> '$x1? $x $x2? $x5? $x7_3 $x9a10_3?',

        re_num => '[໑໒໓໔໕໖໗໘໙໐]',
    );

    my %capture_names = (
        'x'                     => 'consonant',
        'x0_\d'                 => 'vowel0',
        'x1'                    => 'h',
        'x2'                    => 'semivowel',
        'x3'                    => 'vowel1',
        'x(?:3|4_[1-9t]{1,3})'  => 'vowel1',
        'x5'                    => 'tonemark',
        'x6(?:_\d)?'            => 'vowel2',
        'x7_\d'                 => 'vowel3',
        'x8(?:3t8)?'            => 'end_consonant',
        'x9'                    => 'foreign_consonant',
        'x10_12'                => 'extra',
        'x10_3'                 => 'cancel',
    );
    my @sorted_x_names = ((sort grep { $_ ne 'x' } keys %capture_names), 'x');

    for my $frag (qw/ x6 x9a10_3 /, sort grep { /^re/ } keys %e) {
        for my $atom (@sorted_x_names) {
            $e{$frag} =~ s/\$($atom)/sprintf '(?<%s> %s)', $capture_names{$atom}, $e{$1}/eg;
        }
    }

    my $syl = "(?: (?:
    (?: $e{re1_all} (?: $e{re1_1} | $e{re1_2} | $e{re1_3} | $e{re1_4} | $e{re1_5} | $e{re1_6} | $e{re1_8} ) ) |
    (?: $e{re2_all} (?: $e{re2_1} | $e{re2_2} | $e{re2_3} ) ) |
    (?: $e{re3_all} (?: $e{re3_1} | $e{re3_2} | $e{re3_3} ) ) |
    $e{re4}  | $e{re5}  | $e{re6}  | $e{re7}  | $e{re8}  | $e{re9}  | $e{re10} |
    $e{re11} | $e{re12} | $e{re13} | $e{re14} ) $e{x10_12}? | $e{re_num}+ )";

    #warn "$syl\n";

    return qr/ $syl /x;
}

sub syllable_full {
    my $syl = syllable_short();
    return qr/ $syl (?=$syl|\P{Lao}|\s+|$) /x;
}

1;
