#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open qw/ :encoding(UTF-8) :std /;
use Test::More;
use Lingua::LO::Transform::Classify;

my %tests = (
    'ກໍ' => {},
    'ກໍ່' => {},
    'ກໍ໋' => {},
    'ກວໍ' => {},
    'ກວໍ້' => {},
    'ກວໍ໊' => {},
    'ກວກ' => {},
    'ກວງ' => {},
    'ກ່ວງ' => {},
    'ກວ່ວຍ' => {},
    'ກວ້ອງ' => {},
    'ກວອັບ' => {},
    'ກວະ' => {},
    'ກວ່ະ' => {},
    'ກວັດ' => {},
    #'ກວັ໋ອມ' => {},
    #'ກວັຽກ' => {},
    'ກວ໊າ' => {},
    'ກວຽດ' => {},
    'ກາ' => {},
    'ກ່າ' => {},
    'ກາຍ' => {},
    'ກ່າຍ' => {},
    'ກິ' => {},
    'ກິ່' => {},
    'ກ໋ຽວ' => {},
    'ເກ' => {},
    'ເກວວ' => {},
    'ເກວື໊ອນ' => {},
    'ເກາະ' => {},
    'ເກ່າະ' => {},
    'ເກິ່ຍ' => {},
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

