package Lingua::LO::NLP;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1_007');
use Lingua::LO::NLP::Syllabify;
use Lingua::LO::NLP::Analyze;
use Lingua::LO::NLP::Romanize;

=encoding UTF-8

=head1 NAME

Lingua::LO::NLP - Various Lao text processing functions

=head1 SYNOPSIS

    use Lingua::LO::NLP;
    use Data::Dumper;
    use utf8;

    my $lao = Lingua::LO::NLP->new;

    my @syllables = $lao->split_to_syllables("ສະບາຍດີ"); # qw( ສະ ບາຍ ດີ )
    print Dumper(\@syllables);

    for my $syl (@syllables) {
        my $analysis = $lao->analyze_syllable($syl);
        printf "%s: %s\n", $analysis->syllable, $analysis->tone;
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

    new(option =E<gt> value, ...)

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

    my @syllables = $object-E<gt>split_to_syllables(text =E<gt> $text, %options );

Split Lao text into its syllables. Uses a regexp modelled after PHISSAMAY,
DALALOY and DURRANI: I<Syllabification of Lao Script for Line Breaking>. Takes
as its only parameter a character string to split and returns a list of
syllables.

=cut
sub split_to_syllables {
    shift;  # discard $self for now
    return Lingua::LO::NLP::Syllabify->new(@_)->get_syllables;
}

=head2 analyze_syllable

    my $classified = $object-E<gt>analyze_syllable($syllable, %options);

Returns a L<Lingua::LO::NLP::Analyze> object that allows you to query
various syllable properties such as core consonant, tone mark, vowel length and
tone. See there for details.

=cut
sub analyze_syllable {
    shift;  # discard $self for now
    return Lingua::LO::NLP::Analyze->new(@_);
}

=head2 romanize

    $object-E<gt>romanize($lao, %options);

Returns a romanized version of the text passed in as C<$lao>. See L<Lingua::LO::NLP::Romanize/new> for options. If you don't pass in I<any> options, the defaults are
C<variant =E<gt> 'PCGN'> and C<hyphenate =E<gt> 1>.

=cut
sub romanize {
    my (undef, $lao, %options) = @_;
    $options{variant} //= 'PCGN';
    $options{hyphenate} //= 1;
    return Lingua::LO::NLP::Romanize->new(%options)->romanize( $lao );
}

=head1 SEE ALSO

L<Lingua::LO::Romanize> is the module that inspired this one. It has some
issues with ambiguous syllable boundaries as in "ໃນວົງ" though.
