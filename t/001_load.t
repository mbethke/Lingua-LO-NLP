#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use open ':encoding(UTF-8)', ':std';
use Test::More tests => 6;

BEGIN {
    use_ok('Lingua::LO::Transform::Data');
    use_ok('Lingua::LO::Transform::Syllables');
    use_ok('Lingua::LO::Transform::Analyze');
    use_ok('Lingua::LO::Transform::Romanize');
    use_ok('Lingua::LO::Transform::Romanize::PCGN');
    use_ok('Lingua::LO::Transform');
}



