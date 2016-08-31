package Lingua::LO::Transform::Syllables;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1');
use charnames qw/ :full lao /;
use Carp;
use Unicode::Normalize qw/ NFD reorder /;
use Class::Accessor::Fast 'antlers';

has text => (is => 'ro');

my ($syl_re, $complete_syl_re) = _make_regexp();

sub new {
    my $class = shift;
    my %opts = @_;
    croak("`text' key missing or undefined") unless defined $opts{text};
    return bless $class->SUPER::new( {
            text => reorder(NFD($opts{text})),
        }
    ), $class;
}

sub get_syllables {
    return shift->text =~ m/($complete_syl_re)/og;
}

sub get_fragments {
    my $self = shift;
    my $t = $self->text;
    my @matches;
    while($t =~ /\G($complete_syl_re | .+?(?=$complete_syl_re|$) )/oxgcs) {
        my $match = $1;
        push @matches, { text => $match, is_lao => scalar($match =~ /^$syl_re/) };
    }
    return @matches
}


sub _make_regexp {
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
    my $x7 = "[${x7_1}${x7_2}${x7_3}";

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

    my $syl = "(?:
    (?: $re1_all (?: $re1_1 | $re1_2 | $re1_3 | $re1_4 | $re1_5 | $re1_6 | $re1_8 ) ) |
    (?: $re2_all (?: $re2_1 | $re2_2 | $re2_3 ) ) |
    (?: $re3_all (?: $re3_1 | $re3_2 | $re3_3 ) ) |
    $re4  | $re5  | $re6  | $re7  | $re8  | $re9  | $re10 |
    $re11 | $re12 | $re13 | $re14 | $re_num+)";

    #print "$syl\n";
    #print "\\G($syl | .+?(?=$syl|\$) )\n";

    return qr/ $syl /x, qr/ $syl (?=$syl|\P{Lao}|\s+|$) /x;
}

