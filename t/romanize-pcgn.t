#!/usr/bin/perl
BEGIN { use lib -d 't' ? "t/lib" : "lib"; }
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use charnames qw/ :full lao /;
use open qw/ :encoding(UTF-8) :std /;
use Test::More;
use Test::Fatal;
use Lingua::LO::NLP::Romanize;

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
    'ຊອຍ'       => 'xoy',
    'ສະບາຍດີ foo bar ສະ' => 'sa-bay-di foo bar sa',
    'ຫນ່າງກັນຍຸງ'  => 'nang-kan-gnoung',
    'ພອຍໄພລິນ'   => 'phoy-phai-lin',
    'ຄ່ອຍໆ'      => 'khoy-khoy',
    'ມາຕີອາຊ໌'    => 'ma-ti-a',   # TODO?
);
@tests % 2 and BAIL_OUT('BUG: set up \@tests correctly!');

like(
    exception { Lingua::LO::NLP::Romanize->new(hyphenate => 1) },
    qr/`variant' arg missing/,
    'Dies w/o "variant" arg'
);
my $r = Lingua::LO::NLP::Romanize->new(variant => 'PCGN', hyphenate => 1);
isa_ok($r, 'Lingua::LO::NLP::Romanize::PCGN');

while(my $word = shift @tests) {
    my $romanized = shift @tests;
    is($r->romanize($word), $romanized, "$word romanized to `$romanized'");
}

# No hyphentaion
is(
    Lingua::LO::NLP::Romanize->new(variant => 'PCGN')->romanize('ສະບາຍດີ'), 'sa bay di',
    "ສະບາຍດີ => 'sa bay di'"
);

# Broken plugin
like(
    exception { Lingua::LO::NLP::Romanize->new(variant => 'Faulty')->romanize('ຟູ') },
    qr/Lingua::LO::NLP::Romanize::Faulty must implement romanize_syllable\(\)/,
    'romanize_syllable is virtual'
);

# romanize_syllable as class method
like(
    exception { Lingua::LO::NLP::Romanize->romanize_syllable('ຟູ') },
    qr/romanize_syllable is not a class method/,
    'romanize_syllable enforces object method call'
);

done_testing;

