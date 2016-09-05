package Lingua::LO::Transform::Syllables;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1');
use charnames qw/ :full lao /;
use Carp;
use Unicode::Normalize qw/ NFD reorder /;
use Class::Accessor::Fast 'antlers';
use Lingua::LO::Transform::Regexp;

has text => (is => 'ro');

my $syl_re = Lingua::LO::Transform::Regexp::syllable_short();
my $complete_syl_re = Lingua::LO::Transform::Regexp::syllable_full();

sub new {
    my $class = shift;
    my %opts = @_;
    croak("`text' key missing or undefined") unless defined $opts{text};
    return bless $class->SUPER::new( {
            text => reorder(NFD($opts{text})),
        }
    ), $class;
}

sub get_syllables {
    return shift->text =~ m/($complete_syl_re)/og;
}

sub get_fragments {
    my $self = shift;
    my $t = $self->text;
    my @matches;
    while($t =~ /\G($complete_syl_re | .+?(?=$complete_syl_re|$) )/oxgcs) {
        my $match = $1;
        push @matches, { text => $match, is_lao => scalar($match =~ /^$syl_re/) };
    }
    return @matches
}

1;
