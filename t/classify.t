#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open qw/ :encoding(UTF-8) :std /;
use Test::More;
use Lingua::LO::Transform::Classify;

my %tests = (
#    'ກໍ' => {},
#    'ກໍ່' => {},
#    'ກໍ໋' => {},
#    'ກວໍ' => {},
#    'ກວໍ້' => {},
#    'ກວໍ໊' => {},
#    'ກວກ' => {},
#    'ກວງ' => {},
#    'ກ່ວງ' => {},
#    'ກວ່ວຍ' => {},
#    'ກວ້ອງ' => {},
#    #'ກວອັບ' => {},
#    'ກວະ' => {},
#    'ກວ່ະ' => {},
#    'ກວັດ' => {},
#    #'ກວັ໋ອມ' => {},
#    #'ກວັຽກ' => {},
#    'ກວ໊າ' => {},
#    'ກວຽດ' => {},
#    'ກາ' => {},
#    'ກ່າ' => {},
#    'ກາຍ' => {},
#    'ກ່າຍ' => {},
#    'ກິ' => {},
#    'ກິ່' => {},
#    'ກ໋ຽວ' => {},
#    'ເກ' => {},
#    'ເກວວ' => {},
#    'ເກວື໊ອນ' => {},
#    'ເກາະ' => {},
#    'ເກ່າະ' => {},
#    'ເກິ່ຍ' => {},
#    'ສວວມ' => {},
#    'ຫງ໋ຽງ' => {},
#    'ຫາມ' => {},

    'ກະ'   => { long => 0 },
    #    'ກັ'    => { long => 0 },
    'ກາ'   => { long => 1 },

    'ກິ'    => { long => 0 },
    'ກິ'    => { long => 1 },

    'ກຶ'    => { long => 0 },
    'ກື'    => { long => 1 },

    'ກຸ'    => { long => 0 },
    'ກູ'    => { long => 1 },

    'ເກະ'  => { long => 0 },
    'ເກັ'   => { long => 0 },
    'ເກ'   => { long => 1 },

    'ແກະ'  => { long => 0 },
    'ແກັ'   => { long => 0 },
    'ແກ'   => { long => 1 },

    'ໂກະ'  => { long => 0 },
    #'ກົ'    => { long => 0 },
    'ໂກ'   => { long => 1 },

    'ເກາະ' => { long => 0 },
    #'ກັອກ'  => { long => 0 },
    'ກໍ'    => { long => 1 },
    'ກອດ'  => { long => 1 },

    'ເກິ'   => { long => 0 },
    'ເກີ'   => { long => 1 },

    ###' Diphthongs
    'ເກັຍ'  => { long => 0 },
    #'ກັຽ'   => { long => 0 },
    'ເກຍ'  => { long => 1 },
    #'ກຽ'   => { long => 1 },

    'ເກຶອ'  => { long => 0 },
    'ເກືອ'  => { long => 1 },

    #'ກົວະ'  => { long => 0 },
    'ກັວກ'  => { long => 0 },
    #'ກົວ'   => { long => 1 },
    'ກວດ'  => { long => 1 },

    'ໄກ'   => { long => 1 },
    'ໃກ'   => { long => 1 },
    'ກາຍ'  => { long => 1 },
    'ກັຍ'   => { long => 0 },

    'ເກົາ'  => { long => 0 },
    'ກໍາ'   => { long => 0 },  # /am/, decomposed
    'ກຳ'   => { long => 0 },  # /am/, composed
);

isa_ok(Lingua::LO::Transform::Classify->new('ສະ'), 'Lingua::LO::Transform::Classify');
for my $syllable (sort keys %tests) {
    print "$syllable => " . print_struct(Lingua::LO::Transform::Classify::classify($syllable)) . "\n";
}
sub print_struct {
    my %s = @_;
    return sprintf('{ %s }', join(", ", map { "$_ => '$s{$_}'" } sort keys %s));
}
done_testing;

