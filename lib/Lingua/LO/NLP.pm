package Lingua::LO::NLP;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1_005');
use Lingua::LO::NLP::Syllabify;
use Lingua::LO::NLP::Analyze;

=encoding UTF-8

=head1 NAME

Lingua::LO::NLP - Various Lao text processing functions

=head1 SYNOPSIS

    use Lingua::LO::NLP;
    use Data::Dumper;
    use utf8;
    my $laotr = Lingua::LO::NLP->new;
    my @syllables = $laotr->split_to_syllables("ສະບາຍດີ"); # qw( ສະ ບາຍ ດີ )
    print Dumper(\@syllables);
    for my $syl (@syllables) {
        my $clas = $laotr->analyze_syllable($syl);
        printf "%s: %s\n", $clas->syllable, $clas->tone;
        # ສະ: TONE_HIGH_STOP
        # ບາຍ: TONE_LOW
        # ດີ: TONE_LOW
    }

=head1 DESCRIPTION

This module provides various functions for processing Lao text. Currently it can

=over 4

=item Split Lao text (usually written without blanks between words) into syllables

=item Analyze syllables with regards to core and end consonants, vowels, tone and
other properties

=item Romanize Lao text according to the PCGN standard

=back

These functions are basically just shortcuts to the functionality of some
specialized modules: L<Lingua::LO::NLP::Syllabify>,
L<Lingua::LO::NLP::Analyze> and L<Lingua::LO::NLP::Romanize>. If
you need only one of them, you can shave off a little overhead by using those
directly.

=head1 METHODS

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
    return Lingua::LO::NLP::Syllabify::split_to_syllables($_[1]);
}

=head2 analyze_syllable

C<my $classified = $object-E<gt>analyze_syllable($syllable);>

Returns a L<Lingua::LO::NLP::Analyze> object that allows you to query
various syllable properties such as core consonant, tone mark, vowel length and
tone. See there for details.

=cut
sub analyze_syllable {
    return Lingua::LO::NLP::Analyze->new($_[1]);
}

=head1 SEE ALSO

L<Lingua::LO::Romanize> is the module that inspired this one, and if you need
only romanization you should give it a try. It is vastly simpler and faster by
a factor of about 10 but does have problems with ambiguous syllable boundaries
as in "ໃນວົງ" and certain semivowel combinations as in "ດ້ວຍ", the latter of
which would probably be fixable but the former are very difficult without going
for a full syllable parse like this module does.
