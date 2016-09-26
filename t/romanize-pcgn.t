#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open qw/ :encoding(UTF-8) :std /;
use Test::More;
use Lingua::LO::Transform::Romanize;

my %tests = (
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
);

my $r = Lingua::LO::Transform::Romanize->new(variant => 'PCGN');
isa_ok($r, 'Lingua::LO::Transform::Romanize::PCGN');

for my $word (sort keys %tests) {
    is($r->romanize($word), $tests{$word}, "$word romanized to `$tests{$word}'");
}
done_testing;

