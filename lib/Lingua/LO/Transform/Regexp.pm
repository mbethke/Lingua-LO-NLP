package Lingua::LO::Transform::Regexp;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1');
use charnames qw/ :full lao /;

# Regular expression fragments. The cryptic names correspond to the naming
# in PHISSAMAY at al: Syllabification of Lao Script for Line Breaking
my %regexp_fragments = (
    x0_1    => 'ເ',
    x0_2    => 'ແ',
    x0_3    => 'ໂ',
    x0_4    => 'ໄ',
    x0_5    => 'ໃ',

    x1      => 'ຫ',

    x       => '[ກຂຄງຈສຊຍດຕຖທນບປຜຝພຟມຢຣລວຫອຮໜໝ]',

    x2      => "[\N{LAO SEMIVOWEL SIGN LO}ຣວລ]",

    x3      => "[\N{LAO VOWEL SIGN U}\N{LAO VOWEL SIGN UU}]",

    x4_12   => "[\N{LAO VOWEL SIGN I}\N{LAO VOWEL SIGN II}]",
    x4_34   => "[\N{LAO VOWEL SIGN Y}\N{LAO VOWEL SIGN YY}]",
    x4_5    => "\N{LAO NIGGAHITA}",
    x4_6    => "\N{LAO VOWEL SIGN MAI KON}",
    x4_7    => "\N{LAO VOWEL SIGN MAI KAN}",
    x4_1t4  => "[\N{LAO VOWEL SIGN I}\N{LAO VOWEL SIGN II}\N{LAO VOWEL SIGN Y}\N{LAO VOWEL SIGN YY}]",

    x5      => "[\N{LAO TONE MAI EK}\N{LAO TONE MAI THO}\N{LAO TONE MAI TI}\N{LAO TONE MAI CATAWA}]",

    x6_1    => 'ວ',
    x6_2    => 'ອ',
    x6_3    => 'ຽ',
    x6      => '[ວອຽ]',

    x7_1    => 'ະ',
    x7_2    => 'າ',
    x7_3    => "\N{LAO VOWEL SIGN AM}",

    x8_3t8  => '[ຍດນມຢບ]',
    x8      => '[ກງຍດນມຢບວ]',

    x9      => '[ຈສຊພຟລ]',

    x10_12  => '[ຯໆ]',
    x10_3   => "\N{LAO CANCELLATION MARK}",

    x9a10_3 => '(?: $x9 $x10_3)',

    re1_all => '$x0_1 $x1? $x $x2?',
    re1_1   => '$x5? $x8? $x9a10_3?',
    re1_2   => '$x4_12 $x5? $x8? $x9a10_3?',
    re1_3   => '$x4_34 $x5? $x6_2 $x8? $x9a10_3?',
    re1_4   => '$x7_2? $x7_1',
    re1_5   => '$x4_6 $x5? $x7_2',
    re1_6   => '$x4_7 $x5? $x8  $x9a10_3?',
    re1_8   => '$x4_7? $x5? $x6_3',

    re2_all => '$x0_2 $x1? $x $x2?',
    re2_1   => '$x5? $x6? $x8? $x9a10_3?',
    re2_2   => '$x7_1',
    re2_3   => '$x4_7 $x5? $x8 $x9a10_3?',

    re3_all => '$x0_3 $x1? $x $x2?',
    re3_1   => '$x5? $x8? $x9a10_3?',
    re3_2   => '$x7_1',
    re3_3   => '$x4_7 $x5? $x8_3t8?',

    re4     => '$x0_4 $x1? $x $x2? $x5? $x6_1? $x9a10_3?',

    re5     => '$x0_5 $x1? $x $x2? $x5? $x6_1?',

    re6     => '$x1? $x $x2? $x3 $x5? $x8? $x9a10_3?',

    re7     => '$x1? $x $x2? $x4_1t4 $x5? $x8? $x9a10_3?',

    re8     => '$x1? $x $x2? $x4_5 $x5? $x7_2? $x9a10_3?',

    re9     => '$x1? $x $x2? $x4_6 $x5? (?: $x8 $x9a10_3? | $x6_1 $x7_1 )',

    re10    => '$x1? $x $x2? $x4_7 $x5? $x6_1? $x8 $x9a10_3?',

    re11    => '$x1? $x $x2? $x5? $x6 $x8 $x9a10_3?',

    re12    => '$x1? $x $x2? $x5? $x7_1',

    re13    => '$x1? $x $x2? $x5? $x7_2 $x8? $x9a10_3?',

    re14    => '$x1? $x $x2? $x5? $x7_3 $x9a10_3?',

    re_num  => '[໑໒໓໔໕໖໗໘໙໐]',
);
# Functional names for all the x-something groups from the original paper
my %capture_names = (
    'x'             => 'consonant',
    'x0_\d'         => 'vowel0',
    'x1'            => 'h',
    'x2'            => 'semivowel',
    'x3'            => 'vowel1',
    'x4_[1-9t]{1,3}'=> 'vowel1',
    'x5'            => 'tone_mark',
    'x6'            => 'vowel2',
    'x6_\d'         => 'vowel2',
    'x7_\d'         => 'vowel3',
    'x8'            => 'end_consonant',
    'x8_3t8'        => 'end_consonant',
    'x9'            => 'foreign_consonant',
    'x10_12'        => 'extra',
    'x10_3'         => 'cancel',
);
# Substitute longer fragment names first so their matches don't get swallowed
# by the shorter ones.
my @sorted_x_names = ('x9a10_3', reverse sort { length $a <=> length $b } keys %capture_names);
# There are two regexp building blocks that need to be listed first
my @fragment_subst_names = ('x9a10_3', sort grep { /^re/ } keys %regexp_fragments);

sub _assemble_regexp {
    my $fragments = shift;
    our %e;
    *e = $fragments;

    return "(?: (?:
    (?: $e{re1_all} (?: $e{re1_1} | $e{re1_2} | $e{re1_3} | $e{re1_4} | $e{re1_5} | $e{re1_6} | $e{re1_8} ) ) |
    (?: $e{re2_all} (?: $e{re2_1} | $e{re2_2} | $e{re2_3} ) ) |
    (?: $e{re3_all} (?: $e{re3_1} | $e{re3_2} | $e{re3_3} ) ) |
    $e{re4}  | $e{re5}  | $e{re6}  | $e{re7}  | $e{re8}  | $e{re9}  | $e{re10} |
    $e{re11} | $e{re12} | $e{re13} | $e{re14} ) $e{x10_12}? | $e{re_num}+ )";
}

sub syllable_short {
    my %fragments = %regexp_fragments;  # full copy as we'll be modifying it

    # Just do some manual scalar interpolation. This could be done at compile time
    # but we need the flexibility for inserting named captures below
    for my $frag (@fragment_subst_names) {
        for my $atom (@sorted_x_names) {
            $fragments{$frag} =~ s/\$($atom)/$fragments{$1}/eg;
        }
    }

    my $syl = _assemble_regexp(\%fragments);
    $ENV{DEBUG} and say $syl;
    return qr/ $syl /x;
}

sub syllable_named {
    my %fragments = %regexp_fragments;  # full copy as we'll be modifying it

    for my $frag (@fragment_subst_names) {
        for my $atom (@sorted_x_names) {
            $fragments{$frag} =~ s/\$($atom)/_named_capture(\%fragments, $atom, $1)/eg;
        }
    }

    my $syl_capture = _assemble_regexp(\%fragments);
    my $syl_short = syllable_short();
    return qr/ $syl_capture (?= \P{Lao} | \s+ | $ | $syl_short )/x;
}

sub syllable_full {
    my $syl_short = syllable_short();
    return qr/ $syl_short (?= \P{Lao} | \s+ | $ | $syl_short ) /x;
}

sub _named_capture {
    my ($fragments, $atom, $match) = @_;
    return defined $capture_names{$atom} ?
    sprintf( '(?<%s> %s)', $capture_names{$atom}, $fragments->{$match} ) :
    $fragments->{$match};
}

1;
