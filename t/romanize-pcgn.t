#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open qw/ :encoding(UTF-8) :std /;
use Test::More;
use Lingua::LO::Transform::Romanize;

my %tests = (
    # Generated syllables from some list or other
    'ສະບາຍດີ'    => 'sa-bay-di',
    'ດີໆ'        => 'di-di',
    'ແຫນ'       => 'hèn',
    'ແໜ '       => 'nè',
);

my $r = Lingua::LO::Transform::Romanize->new(variant => 'PCGN');
isa_ok($r, 'Lingua::LO::Transform::Romanize::PCGN');

for my $word (sort keys %tests) {
    is($r->romanize($word), $tests{$word}, "$word romanized to $tests{$word}");
}
done_testing;

