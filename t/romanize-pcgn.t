#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open qw/ :encoding(UTF-8) :std /;
use Test::More;
use Lingua::LO::Transform::Romanize;

my @tests = (
    'ເຄື່ອງກໍາເນີດໄຟຟ້າ' => 'khuang-kam-neut-fai-fa',
    'ສະບາຍດີ'    => 'sa-bay-di',
    'ດີໆ'        => 'di-di',
    'ແຫນ'       => 'hèn',
    'ແໜ'        => 'nè',
    'ຫົກສິບ'      => 'hôk-sip',
    'ມື້ນີ້'        => 'mu-ni',
    'ມື້ວານນີ້'     => 'mu-van-ni',
    'ໃຫຍ່'       => 'gnai',
    'ຕົວ'        => 'toua',
    'ຄົນ'        => 'khôn',
    'ໃນວົງ'      => 'nai-vông',
    'ເຫຼົາ'       => 'lao',
    'ເຫງ'       => 'héng',
    'ຫວາດ'      => 'vat',
    'ເສລີ'       => 'sleu',
    'ຄວາມ'      => 'khoam',
    'ຫຼາຍ'       => 'lay',
);
@tests % 2 and BAIL_OUT('BUG: set up \@tests correctly!');

my $r = Lingua::LO::Transform::Romanize->new(variant => 'PCGN', hyphenate => 1);
isa_ok($r, 'Lingua::LO::Transform::Romanize::PCGN');

while(my $word = shift @tests) {
    my $romanized = shift @tests;
    is($r->romanize($word), $romanized, "$word romanized to `$romanized'");
}
done_testing;

