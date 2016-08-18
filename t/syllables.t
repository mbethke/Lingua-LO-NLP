#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use feature 'unicode_strings';
use open ':encoding(UTF-8)', ':std';
use Test::More;
use Lingua::LO::Transform::Syllables;

my %tests = (
    ສະບາຍດີ      => [ qw/ ສະ ບາຍ ດີ / ],
    ກວ່າດອກ      => [ qw/ ກວ່າ ດອກ /],
    ຜູ້ເຂົ້າ        => [ qw/ ຜູ້ ເຂົ້າ /],
    ""          => [],
    ກວ່າດອກ໐໑໒໓  => [ qw/ ກວ່າ ດອກ ໐໑໒໓ /],
    ຄຳດີ         => [ qw/ ຄຳ ດີ /],   # composed sala am
    ຄໍາດີ         => [ qw/ ຄໍາ ດີ /],   # decomposed sala am
    ຄໍາູດີ         => [ qw/ ດີ /],      # malformed first syllable "khamu" dropped
);

my $o = Lingua::LO::Transform::Syllables->new(text => 'ສະບາຍດີ');
isa_ok($o, 'Lingua::LO::Transform::Syllables');

for my $text (sort keys %tests) {
    $o = Lingua::LO::Transform::Syllables->new(text => $text);
    my $syl = [ $o->get_syllables ];
    #use Data::Dumper; print Dumper($syl);
    is_deeply($syl, $tests{$text}, "`$text' split correctly");
}
done_testing;

