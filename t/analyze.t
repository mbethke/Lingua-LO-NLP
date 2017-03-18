#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open qw/ :encoding(UTF-8) :std /;
use charnames qw/ :full lao /;
use Test::More;
use Test::Fatal;
use Lingua::LO::NLP::Analyze;

use constant MAI_EK     => "\N{LAO TONE MAI EK}";
use constant MAI_THO    => "\N{LAO TONE MAI THO}";
use constant MAI_CATAWA => "\N{LAO TONE MAI CATAWA}";

my %tests = (
    # Generated syllables from some list or other
    'ກວກ' => { consonant => 'ກ', end_consonant => 'ກ', tone => 'LOW', vowel => 'Xວ', vowel_length => 'long' },
    'ກວງ' => { consonant => 'ກ', end_consonant => 'ງ', tone => 'LOW', vowel => 'Xວ', vowel_length => 'long' },
    'ກ່ວງ' => { consonant => 'ກ', end_consonant => 'ງ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xວ', vowel_length => 'long' },
    'ກ່າ' => { consonant => 'ກ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xາ', vowel_length => 'long' },
    'ກ່າຍ' => { consonant => 'ກ', end_consonant => 'ຍ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xາ', vowel_length => 'long' },
    'ກໍ' => { consonant => 'ກ', tone => 'LOW', vowel => 'Xໍ', vowel_length => 'long' },
    'ກໍ່' => { consonant => 'ກ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xໍ', vowel_length => 'long' },
    'ກໍ໋' => { consonant => 'ກ', tone => 'LOW_RISING', tone_mark => MAI_CATAWA, vowel => 'Xໍ', vowel_length => 'long' },
    'ແໜ' => { consonant => 'ໜ', tone => 'LOW_RISING', vowel => 'ແX', vowel_length => 'long' },
    'ແຫນ' => { consonant => 'ຫ', end_consonant => 'ນ', tone => 'LOW_RISING', vowel => 'ແX', vowel_length => 'long' },
    'ຫາມ' => { consonant => 'ຫ', end_consonant => 'ມ', tone => 'LOW_RISING', vowel => 'Xາ', vowel_length => 'long' },
    'ເກິ່ຍ' => { consonant => 'ກ', end_consonant => 'ຍ', tone => 'MID', tone_mark => MAI_EK, vowel => 'ເXິ', vowel_length => 'short' },

    # Constructed syllables with simple vowels
    'ກະ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'Xະ', vowel_length => 'short' },
    'ກາ' => { consonant => 'ກ', tone => 'LOW', vowel => 'Xາ', vowel_length => 'long' },

    'ກິ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'Xິ', vowel_length => 'short' },
    'ກີ' => { consonant => 'ກ', tone => 'LOW', vowel => 'Xີ', vowel_length => 'long' },

    'ກຶ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'Xຶ', vowel_length => 'short' },
    'ກື' => { consonant => 'ກ', tone => 'LOW', vowel => 'Xື', vowel_length => 'long' },

    'ກຸ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'Xຸ', vowel_length => 'short' },
    'ກູ' => { consonant => 'ກ', tone => 'LOW', vowel => 'Xູ', vowel_length => 'long' },

    'ເກະ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'ເXະ', vowel_length => 'short' },
    'ເກັນ' => { consonant => 'ກ', end_consonant => 'ນ', tone => 'HIGH', vowel => 'ເXັ', vowel_length => 'short' },
    'ເກ' => { consonant => 'ກ', tone => 'LOW', vowel => 'ເX', vowel_length => 'long' },

    'ແກະ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'ແXະ', vowel_length => 'short' },
    'ແກັດ' => { consonant => 'ກ', end_consonant => 'ດ', tone => 'HIGH', vowel => 'ແXັ', vowel_length => 'short' },
    'ແກ' => { consonant => 'ກ', tone => 'LOW', vowel => 'ແX', vowel_length => 'long' },

    'ໂກະ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'ໂXະ', vowel_length => 'short' },
    'ໂກ' => { consonant => 'ກ', tone => 'LOW', vowel => 'ໂX', vowel_length => 'long' },

    'ກັນ' => { consonant => 'ກ', end_consonant => 'ນ', tone => 'HIGH', vowel => 'Xັ', vowel_length => 'short' },
    'ກົດ' => { consonant => 'ກ', end_consonant => 'ດ', tone => 'HIGH', vowel => 'Xົ', vowel_length => 'short' },

    'ເກາະ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'ເXາະ', vowel_length => 'short' },
    'ກໍ' => { consonant => 'ກ', tone => 'LOW', vowel => 'Xໍ', vowel_length => 'long' },
    'ກອດ' => { consonant => 'ກ', end_consonant => 'ດ', tone => 'LOW', vowel => 'Xອ', vowel_length => 'long' },

    'ເກິ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'ເXິ', vowel_length => 'short' },
    'ເກີ' => { consonant => 'ກ', tone => 'LOW', vowel => 'ເXີ', vowel_length => 'long' },

    ###' Diphthongs
    'ເກັຍ' => { consonant => 'ກ', end_consonant => 'ຍ', tone => 'HIGH', vowel => 'ເXັ', vowel_length => 'short' },
    'ເກຍ' => { consonant => 'ກ', end_consonant => 'ຍ', tone => 'LOW', vowel => 'ເX', vowel_length => 'long' },

    'ເກົາ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'ເXົາ', vowel_length => 'short' },

    'ເກຶອ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'ເXຶອ', vowel_length => 'short' },
    'ເກືອ' => { consonant => 'ກ', tone => 'LOW', vowel => 'ເXືອ', vowel_length => 'long' },

    'ກວດ' => { consonant => 'ກ', end_consonant => 'ດ', tone => 'LOW', vowel => 'Xວ', vowel_length => 'long' },
    'ກັວກ' => { consonant => 'ກ', end_consonant => 'ກ', syllable => 'ກັວກ', tone => 'HIGH', vowel => 'Xັວ', vowel_length => 'short' },

    'ໄກ' => { consonant => 'ກ', tone => 'LOW', vowel => 'ໄX', vowel_length => 'long' },
    'ໃນ' => { consonant => 'ນ', tone => 'HIGH', vowel => 'ໃX', vowel_length => 'long' },
    'ກາຍ' => { consonant => 'ກ', end_consonant => 'ຍ', tone => 'LOW', vowel => 'Xາ', vowel_length => 'long' },
    'ກັຍ' => { consonant => 'ກ', end_consonant => 'ຍ', tone => 'HIGH', vowel => 'Xັ', vowel_length => 'short' },

    'ແປຽ' => { consonant => 'ປ', tone => 'HIGH', vowel => 'ແXຽ', vowel_length => 'short' },
    'ກໍາ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'Xໍາ', vowel_length => 'short' },  # /am/, decomposed
    'ກຳ' => { consonant => 'ກ', tone => 'HIGH', vowel => 'Xຳ', vowel_length => 'short' },  # /am/, composed

    # Various cases that have looked problematic
    'ກຽດ' => { consonant => 'ກ', end_consonant => 'ດ', tone => 'LOW', vowel => 'Xຽ', vowel_length => 'long' },
    'ຈື່ງ' => { consonant => 'ຈ', end_consonant => 'ງ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xື', vowel_length => 'long' },
    'ຊັນ' => { consonant => 'ຊ', end_consonant => 'ນ', tone => 'MID', vowel => 'Xັ', vowel_length => 'short' },
    'ຊົ່ວ' => { consonant => 'ຊ', end_consonant => 'ວ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xົ', vowel_length => 'short' },
    'ຍະ' => { consonant => 'ຍ', tone => 'MID', vowel => 'Xະ', vowel_length => 'short' },
    'ດີ' => { consonant => 'ດ', tone => 'LOW', vowel => 'Xີ', vowel_length => 'long' },
    'ດ້ວຍ' => { consonant => 'ດ', end_consonant => 'ຍ', tone => 'HIGH_FALLING', tone_mark => MAI_THO, vowel => 'Xວ', vowel_length => 'long' },
    'ຕິ' => { consonant => 'ຕ', tone => 'HIGH', vowel => 'Xິ', vowel_length => 'short' },
    'ຕົນ' => { consonant => 'ຕ', end_consonant => 'ນ', tone => 'HIGH', vowel => 'Xົ', vowel_length => 'short' },
    'ຕ້ອງ' => { consonant => 'ຕ', end_consonant => 'ງ', tone => 'HIGH_FALLING', tone_mark => MAI_THO, vowel => 'Xອ', vowel_length => 'long' },
    'ຕໍ່' => { consonant => 'ຕ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xໍ', vowel_length => 'long' },
    'ທາງ' => { consonant => 'ທ', end_consonant => 'ງ', tone => 'HIGH', vowel => 'Xາ', vowel_length => 'long' },
    'ທຳ' => { consonant => 'ທ', tone => 'MID', vowel => 'Xຳ', vowel_length => 'short' },
    'ນຸດ' => { consonant => 'ນ', end_consonant => 'ດ', tone => 'MID', vowel => 'Xຸ', vowel_length => 'short' },
    'ນ້ອງ' => { consonant => 'ນ', end_consonant => 'ງ', tone => 'HIGH_FALLING', tone_mark => MAI_THO, vowel => 'Xອ', vowel_length => 'long' },
    'ປະ' => { consonant => 'ປ', tone => 'HIGH', vowel => 'Xະ', vowel_length => 'short' },
    'ປັດ' => { consonant => 'ປ', end_consonant => 'ດ', tone => 'HIGH', vowel => 'Xັ', vowel_length => 'short' },
    'ພາບ' => { consonant => 'ພ', end_consonant => 'ບ', tone => 'HIGH', vowel => 'Xາ', vowel_length => 'long' },
    'ພີ່' => { consonant => 'ພ', tone => 'MID', tone_mark => MAI_EK, vowel => 'Xີ', vowel_length => 'long' },
    'ພຶດ' => { consonant => 'ພ', end_consonant => 'ດ', tone => 'MID', vowel => 'Xຶ', vowel_length => 'short' },
    'ມະ' => { consonant => 'ມ', tone => 'MID', vowel => 'Xະ', vowel_length => 'short' },
    'ມາ' => { consonant => 'ມ', tone => 'HIGH', vowel => 'Xາ', vowel_length => 'long' },
    'ມີ' => { consonant => 'ມ', tone => 'HIGH', vowel => 'Xີ', vowel_length => 'long' },
    'ສະ' => { consonant => 'ສ', tone => 'HIGH', vowel => 'Xະ', vowel_length => 'short' },
    'ສັກ' => { consonant => 'ສ', end_consonant => 'ກ', tone => 'HIGH', vowel => 'Xັ', vowel_length => 'short' },
    'ສຳ' => { consonant => 'ສ', tone => 'HIGH', vowel => 'Xຳ', vowel_length => 'short' },
    'ສິດ' => { consonant => 'ສ', end_consonant => 'ດ', tone => 'HIGH', vowel => 'Xິ', vowel_length => 'short' },
    'ຮູ້' => { consonant => 'ຮ', tone => 'HIGH_FALLING', tone_mark => MAI_THO, vowel => 'Xູ', vowel_length => 'long' },
    'ເກີດ' => { consonant => 'ກ', end_consonant => 'ດ', tone => 'LOW', vowel => 'ເXີ', vowel_length => 'long' },
    'ເໝີ' => { consonant => 'ໝ', tone => 'LOW_RISING', vowel => 'ເXີ', vowel_length => 'long' },
    'ແລະ' => { consonant => 'ລ', tone => 'MID', vowel => 'ແXະ', vowel_length => 'short' },
    'ໂນ' => { consonant => 'ນ', tone => 'HIGH', vowel => 'ໂX', vowel_length => 'long' },
    'ໃກ' => { consonant => 'ກ', tone => 'LOW', vowel => 'ໃX', vowel_length => 'long' },
    'ໜ້າ' => { consonant => 'ໜ', tone => 'MID_FALLING', tone_mark => MAI_THO, vowel => 'Xາ', vowel_length => 'long' },
    'ເຫດ' => { consonant => 'ຫ', end_consonant => "ດ", 'tone' => 'LOW_RISING',  'vowel' => "ເX", vowel_length => 'long' },
    'ເອື້ອຢ' => { consonant => "ອ", end_consonant => "ຢ", tone => "HIGH_FALLING", tone_mark => MAI_THO, vowel => "ເ◌ືອ", vowel_length => "long" },
    'ນ້ໍາ' => { consonant => "ນ", syllable => "ນໍ້າ", tone => "HIGH_FALLING", tone_mark => MAI_THO, vowel => "◌ໍາ", vowel_length => "short" },

    # TODO verify
    #'ຢູ່ມ້ີ' => { consonant => "ຢ", syllable => "ຢູ່ມີ້", tone => "MID", tone_mark => MAI_EK, vowel => "◌ູ", vowel_length => "long" },
    #'ຫານ' => { consonant => "ຫ", end_consonant => "ນ", syllable => "ຫານ", tone => "LOW_RISING", vowel => "◌າ", vowel_length => "long" },
    #'ຫິວ' => { consonant => "ຫ", end_consonant => "ວ", syllable => "ຫິວ", tone => "HIGH", vowel => "◌ິ", vowel_length => "short" },
    #'ຫົດ' => { consonant => "ຫ", end_consonant => "ດ", syllable => "ຫົດ", tone => "HIGH", vowel => "◌ົ", vowel_length => "short" },
    #'ເຂ້ົາ' => { consonant => "ຂ", syllable => "ເຂົ້າ", tone => "HIGH", tone_mark => MAI_THO, vowel => "ເ◌ົາ", vowel_length => "short" },
    #'ເຈ້ົາ' => { consonant => "ຈ", syllable => "ເຈົ້າ", tone => "HIGH", tone_mark => MAI_THO, vowel => "ເ◌ົາ", vowel_length => "short" },
    #'ເຕີລ່ີ' => { consonant => "ຕ", syllable => "ເຕີລີ່", tone => "LOW", vowel => "ເ◌ີ", vowel_length => "long" },
    #'ເທົ່າ' => { consonant => "ທ", syllable => "ເທົ່າ", tone => "MID", tone_mark => MAI_EK, vowel => "ເ◌ົາ", vowel_length => "short" },
    #'ເທ່ືອ' => { consonant => "ທ", syllable => "ເທື່ອ", tone => "MID", tone_mark => MAI_EK, vowel => "ເ◌ືອ", vowel_length => "long" },
    #'ເລ້ືອຍໆ' => { consonant => "ລ", end_consonant => "ຍ", syllable => "ເລື້ອຍໆ", tone => "HIGH_FALLING", tone_mark => MAI_THO, vowel => "ເ◌ືອ", vowel_length => "long" },
    #'ເອ້ືອຢ' => { consonant => "ອ", end_consonant => "ຢ", syllable => "ເອື້ອຢ", tone => "HIGH_FALLING", tone_mark => MAI_THO, vowel => "ເ◌ືອ", vowel_length => "long" },

    #'ໄລນ໌' => {},

    # Test tone mark order normalization
    # Regular order consonant-vowel-tone
    "\N{LAO VOWEL SIGN E}\N{LAO LETTER MO}\N{LAO VOWEL SIGN YY}\N{LAO TONE MAI EK}\N{LAO LETTER O}" =>
    { consonant => 'ມ', vowel => 'ເXືອ', tone => 'MID', tone_mark => MAI_EK, vowel_length => 'long' },
    # Wrong order consonant-tone-vowel
    "\N{LAO VOWEL SIGN E}\N{LAO LETTER MO}\N{LAO TONE MAI EK}\N{LAO VOWEL SIGN YY}\N{LAO LETTER O}" =>
    {
        consonant => 'ມ', vowel => 'ເXືອ', tone => 'MID',
        syllable => "\N{LAO VOWEL SIGN E}\N{LAO LETTER MO}\N{LAO VOWEL SIGN YY}\N{LAO TONE MAI EK}\N{LAO LETTER O}",
        tone_mark => MAI_EK, vowel_length => 'long'
    },
);

for my $analysis (values %tests) {
    s/X/\N{DOTTED CIRCLE}/ for values %$analysis;
}

my @tone_tests = (
    ກາ => 'LOW',
    ຄາ => 'HIGH',
    ຂາ => 'LOW_RISING',

    ກ່າ => 'MID',
    ຄ່າ => 'MID',
    ຂ່າ => 'MID',

    ກ້າ => 'HIGH_FALLING',
    ຄ້າ => 'HIGH_FALLING',
    ຂ້າ => 'MID_FALLING',

    ກ໊າ => 'HIGH',
    ຄ໊າ => 'HIGH',
    ຂ໊າ => 'HIGH',

    ກ໋າ => 'LOW_RISING',
    ຄ໋າ => 'LOW_RISING',
    ຂ໋າ => 'LOW_RISING',

    ກະ => 'HIGH',
    ຄະ => 'MID',
    ຂະ => 'HIGH',
);
@tone_tests % 2 and die 'BUG: @tone_tests must have an even number of elements!';

isa_ok(Lingua::LO::NLP::Analyze->new('ສະ'), 'Lingua::LO::NLP::Analyze');
like(
    exception { Lingua::LO::NLP::Analyze->new },
    qr/`syllable' argument missing or undefined/,
    'Dies w/o syllable argument'
);
for my $syllable (sort keys %tests) {
    my %c = %{ Lingua::LO::NLP::Analyze->new($syllable, normalize => 1) };
    #print "'$syllable' => " . print_struct(%c) . "\n";
    #next;
    delete $c{parse};
    delete $c{$_} for grep { not defined $c{$_} } keys %c;
    # trivial, doesn't need to be mentioned above unless it was subject to normalization
    $tests{$syllable}{syllable} //= $syllable;
    is_deeply(\%c, $tests{$syllable}, "`$syllable' analyzed correctly")
        or print "Result for '$syllable': ", (map { "$_ => \"$c{$_}\", " } sort keys %c) , "\n";
}

while(@tone_tests) {
    my $syllable = shift @tone_tests;
    my $tone = shift @tone_tests;
    is(Lingua::LO::NLP::Analyze->new($syllable)->tone, $tone, "$syllable has $tone tone");
}

done_testing;

# Just for adding new tests
sub print_struct {
    my %s = @_;
    return sprintf('{ %s },',
        join(", ",
            map {
                sprintf "%s => %s", $_, ref($s{$_}) ? print_struct(%{$s{$_}}) : "'$s{$_}'"
            }
            grep {
                defined $s{$_} and !/^parse$/
            } sort keys %s
        )
    );
}

