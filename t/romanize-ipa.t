#!/usr/bin/perl
BEGIN { use lib -d 't' ? "t/lib" : "lib"; }
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use charnames qw/ :full lao /;
use open qw/ :encoding(UTF-8) :std /;
use Test::More;
use Lingua::LO::NLP::Romanize;

my @tests = (
    'ເຄື່ອງກໍາເນີດໄຟຟ້າ' => 'kʰɯ̄ːəŋ kám nɤ́ːt fáj fâː',
    'ສະບາຍດີ'    => 'sá bàːj dìː',
    'ດີໆ'        => 'dìː-dìː',
);
@tests % 2 and BAIL_OUT('BUG: set up \@tests correctly!');

my $r = Lingua::LO::NLP::Romanize->new(variant => 'IPA');
isa_ok($r, 'Lingua::LO::NLP::Romanize::IPA');

while(my $word = shift @tests) {
    my $romanized = shift @tests;
    is($r->romanize($word), $romanized, "$word romanized to `$romanized'");
}

done_testing;

