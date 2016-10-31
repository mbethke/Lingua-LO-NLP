# NAME

Lingua::LO::NLP - Various Lao text processing functions

# SYNOPSIS

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

# DESCRIPTION

This module provides various functions for processing Lao text. Currently it can

- Split Lao text (usually written without blanks between words) into syllables
- Analyze syllables with regards to core and end consonants, vowels, tone and
other properties
- Romanize Lao text according to the PCGN standard

These functions are basically just shortcuts to the functionality of some
specialized modules: [Lingua::LO::NLP::Syllabify](https://metacpan.org/pod/Lingua::LO::NLP::Syllabify),
[Lingua::LO::NLP::Analyze](https://metacpan.org/pod/Lingua::LO::NLP::Analyze) and [Lingua::LO::NLP::Romanize](https://metacpan.org/pod/Lingua::LO::NLP::Romanize). If
you need only one of them, you can shave off a little overhead by using those
directly.

# METHODS

## new

`new(option => value, ...)`

The object constructor currently does nothing; there are no options. However,
it is likely that there will be in future versions, therefore it is highly
recommended to call methods as object methods so your code won't break when I
introduce them.

## split\_to\_syllables

`my @syllables = $object->split_to_syllables(text => $text, %options );`

Split Lao text into its syllables. Uses a regexp modelled after PHISSAMAY,
DALALOY and DURRANI: _Syllabification of Lao Script for Line Breaking_. Takes
as its only parameter a character string to split and returns a list of
syllables.

## analyze\_syllable

`my $classified = $object->analyze_syllable($syllable, %options);`

Returns a [Lingua::LO::NLP::Analyze](https://metacpan.org/pod/Lingua::LO::NLP::Analyze) object that allows you to query
various syllable properties such as core consonant, tone mark, vowel length and
tone. See there for details.

# SEE ALSO

[Lingua::LO::Romanize](https://metacpan.org/pod/Lingua::LO::Romanize) is the module that inspired this one. It has some
issues with ambiguous syllable boundaries as in "ໃນວົງ" though.
