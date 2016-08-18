#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use Test::More;
use Lingua::LO::Transform::Classify;

isa_ok(Lingua::LO::Transform::Classify->new('ສະ'), 'Lingua::LO::Transform::Classify');
done_testing;

