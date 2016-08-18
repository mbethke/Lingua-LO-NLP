#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use open ':encoding(UTF-8)', ':std';
use Test::More tests => 2;

BEGIN {
    use_ok('Lingua::LO::Transform::Classify');
    use_ok('Lingua::LO::Transform::Syllables');
}



