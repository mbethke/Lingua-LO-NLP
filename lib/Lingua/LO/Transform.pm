package Lingua::LO::Transform;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Lingua::LO::Transform::Syllables;
use Lingua::LO::Transform::Classify;

=encoding UTF-8

=head1 NAME

Lingua::LO::Transform - Various Lao text processing functions

=head1 SYNOPSIS

    use Lingua::LO::Transform;
    use Data::Dumper;
    use utf8;
    my $laotr = Lingua::LO::Transform->new;
    my @syllables = $laotr->split_to_syllables("ສະບາຍດີ"); # qw( ສະ ບາຍ ດີ )
    print Dumper(\@syllables);
    for my $syl (@syllables) {
        my $clas = $laotr->classify_syllable($syl);
        printf "%s: %s\n", $clas->syllable, $clas->tone;
        # ສະ: TONE_HIGH_STOP
        # ບາຍ: TONE_LOW
        # ດີ: TONE_LOW
    }

=head1 DESCRIPTION

This module provides various functions for processing Lao text. Currently it can

=over 4

=item Split Lao text (usually written without blanks between words) into syllables

=item Classify syllables 

=back

=head1 METHODS
=head2 EXPORT

=head2 new

C<new(option E<gt> value, ...)>

The object constructor currently does nothing; there are no options. However,
it is likely that there will be in future versions, therefore it is highly
recommended to call methods as object methods so your code won't break when I
introduce them.

=cut
sub new {
    my $class = shift;
    my %opts = @_;
    return bless \%opts, $class;
}

=head2 split_to_syllables

C<my @syllables = $object-E<gt>split_to_syllables($text);>

Split Lao text into its syllables. Uses a regexp modelled after Phissamay,
Dalaloy and Durrani: "Syllabification of Lao Script for Line Breaking". Takes
as its only parameter a character string to split and returns a list of
syllables.

=cut
sub split_to_syllables {
    my ($self, $text) = @_;
    return Lingua::LO::Transform::Syllables::split_to_syllables($text);
}

=head2 classify_syllable

C<my $classified = $object-E<gt>classify_syllable($syllable);>

Returns a L<Lingua::LO::Transform::Classify> object that allows you to query
various syllable properties such as core consonant, tone mark, vowel length and
tone. See there for details.

=cut
sub classify_syllable {
    my ($self, $syllable) = @_;
    return Lingua::LO::Transform::Classify->new($syllable);
}

