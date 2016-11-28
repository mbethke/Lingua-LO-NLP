package Lingua::LO::NLP::Romanize::IPA;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature qw/ unicode_strings say /;
use charnames qw/ :full lao /;
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Lingua::LO::NLP::Analyze;
use parent 'Lingua::LO::NLP::Romanize';

=encoding UTF-8

=head1 NAME

Lingua::LO::NLP::Romanize::IPA - Convert Lao syllables to the International Phonetic Alphabet

=head1 FUNCTION

This class is not supposed to be used directly. Rather use
L<Lingua::LO::NLP::Romanize> as a factory:

    my $o = Lingua::LO::NLP::Romanize->new(variant => 'IPA');

Note that this is experimental and probably buggy. The code is the same as
L<Lingua::LO::NLP::Romanize::PCGN> so this should actually be a subclass,
pending a proper way of accessing the class constants. However, I'm not sure
it will stay that way so for now this is not going to be refactored.

=cut

my %CONSONANTS = (
   ກ  => 'k',
   ຂ  => [qw/ kʰ k /],
   ຄ  => [qw/ kʰ k /],
   ງ  => 'ŋ',
   ຈ  => [qw/ tɕ t /],
   ສ  => [qw/ s t /],
   ຊ  => [qw/ s t /],
   ຍ  => 'ɲ',
   ດ  => [qw/ d t /],
   ຕ  => 't',
   ຖ  => [qw/ tʰ t /],
   ທ  => [qw/ tʰ t /],
   ນ  => 'n',
   ບ  => [qw/ b p /],
   ປ  => 'p',
   ຜ  => 'pʰ',
   ຝ  => [qw/ f p /],
   ພ  => [qw/ pʰ p /],
   ຟ  => [qw/ f p /],
   ມ  => 'm',
   ຢ  => 'j',
   ລ  => [qw/ l n /],
   "\N{LAO SEMIVOWEL SIGN LO}"  => 'l',
   ວ  => 'w',   # TODO ʋ?
   ຫ  => 'h',
   ອ  => 'ʔ',
   ຮ  => 'h',
   ຣ  => [qw/ r n /],   # TODO l?
   ໜ  => 'n',
   ໝ  => 'm',
   ຫຼ  => 'l',
   ຫຍ => 'ɲ',
   ຫນ => 'n',
   ຫມ => 'm',
   ຫຣ => 'r',   # TODO l?
   ຫລ => 'l',
   ຫວ => 'w', # TODO ʋ?
);

my %CONS_VOWELS = map { $_ => 1 } qw/ ຍ ຽ ອ ວ /;

my %VOWELS = (
    ### Monophthongs
    'Xະ'   => 'a',
    'Xັ'    => 'a',
    'Xາ'   => 'aː',
    'Xາວ'  => 'aːo',

    'Xິ'    => 'i',
    'Xີ'    => 'iː',

    'Xຶ'    => 'ɯ',
    'Xື'    => 'ɯː',

    'Xຸ'    => 'u',
    'Xູ'    => 'uː',

    'ເXະ'  => 'e',
    'ເXັ'   => 'e',
    'ເX'   => 'eː',

    'ແXະ'  => 'ɛ',
    'ແXັ'   => 'ɛ',
    'ແX'   => 'ɛː',
    'ແXວ'  => 'ɛːo',

    'ໂXະ'  => 'o',
    'Xົ'    => 'o',
    'ໂX'   => 'oː',
    'ໂXຍ'  => 'oːi', # TODO correct?
    'Xອຍ'  => 'oːi',

    'ເXາະ' => 'ɔ',
    'Xັອ'   => 'ɔ',
    'Xໍ'    => 'ɔː',
    'Xອ'   => 'ɔː',

    'ເXິ'   => 'ɤ',
    'ເXີ'   => 'ɤː',
    'ເXື'   => 'ɯːə', # TODO correct?

    'ເXັຍ'  => 'iə',
    'Xັຽ'   => 'iə',
    'ເXຍ'  => 'iːə',
    'Xຽ'   => 'iːə',
    'Xຽວ'  => 'TODO:ຽວ',

    'ເXຶອ'  => 'ɯə',
    'ເXືອ'  => 'ɯːə',

    'Xົວະ'  => 'uə',
    'Xັວ '  => 'uə',
    'Xົວ'   => 'uːə',
    'Xວ'   => 'uːə',
    'Xວຍ'  => 'uːəi',

    'ໄX'   => 'aj',
    'ໃX'   => 'aj',
    'Xາຍ'  => 'aːj',
    'Xັຍ'   => 'aj',

    'ເXົາ'  => 'aw',
    'Xຳ'   => 'am', # composed U+0EB3
    'Xໍາ'   => 'am',
);
{
    # Replace "X" in %VOWELS keys with DOTTED CIRCLE. Makes code easier to edit.
    my %v;
    foreach my $v (keys %VOWELS) {
        (my $w = $v) =~ s/X/\N{DOTTED CIRCLE}/;
        $v{$w} = $VOWELS{$v};
    }
    %VOWELS = %v;
}

my %TONE_DIACRITICS = (
    LOW => "\N{COMBINING GRAVE ACCENT}",
    MID => "\N{COMBINING MACRON}",                          MID_STOP => "\N{COMBINING MACRON}",
    HIGH => "\N{COMBINING ACUTE ACCENT}",                   HIGH_STOP => "\N{COMBINING ACUTE ACCENT}",
    LOW_RISING => "\N{COMBINING CARON}",
    HIGH_FALLING => "\N{COMBINING CIRCUMFLEX ACCENT}",
    MID_FALLING => "\N{COMBINING CIRCUMFLEX ACCENT BELOW}",
);

=head2 new

You don't call this constructor directly bu via L<Lingua::LO::NLP::Romanize>.
It adds the following attribute:

=over 4

=item C<tone>: boolean indicating whether to add dicacritics for tone

=back

=cut

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;
    $self->{romanize_vowel} = $args{tone} ? \&_vowel_with_tone : \&_vowel_without_tone;
    return $self;
}

=head2 romanize_syllable

    romanize_syllable( $syllable )

Return the romanization of a single C<$syllable>. See L<Lingua::LO::NLP::Romanize/romanize_syllable>

=cut

sub romanize_syllable {
    my ($self, $syllable) = @_;
    my ($consonant, $endcons, $result);
    my $c = Lingua::LO::NLP::Analyze->new($syllable);
    my $parse = $c->parse;
    my $vowel = $c->vowel;
    
    my $cons = $c->consonant;
    my $h = $c->h;
    my $sv = $c->semivowel;
    if($cons eq 'ຫ' and $sv) {
        # ຫ with semivowel. Drop the ຫ and use the semivowel as consonant
        $result = _consonant($sv, 0);
    } else {
        # The regular case
        $result = _consonant($cons, 0);
        $result .= _consonant($sv, 1) if $sv;
    }

    $endcons = $c->end_consonant;
    if(defined $endcons) {
        if(exists $CONS_VOWELS{ $endcons }) {
            $vowel .= $endcons;   # consonant can be used as a vowel
            $endcons = '';
        } else {
            $endcons = _consonant($endcons, 1);
        }
    } else {
        $endcons = '';  # avoid special-casing later
    }

    # TODO remove debug
    warn sprintf("Missing VOWELS def for `%s' in `%s'", $vowel, $c->syllable) unless defined $VOWELS{ $vowel };

    $result .= $self->{romanize_vowel}->($vowel, $c->tone) . $endcons;
    # Duplication sign
    if(defined $parse->{extra}  and $parse->{extra} eq 'ໆ') {
        $result .= ($self->{hyphen} eq ' ' ? '-' : $self->{hyphen}) . "$result";
    }
    return $result;
}

sub _vowel_with_tone {
    my ($lao_vowel, $tone) = @_;
    my $vowel = $VOWELS{ $lao_vowel };
    # Insert tone diacritic after first character
    substr($vowel, 1, 0) = $TONE_DIACRITICS{ $tone };
    return $vowel;
}

sub _vowel_without_tone { return $VOWELS{ $_[0] } }

sub _consonant {
    my ($cons, $position) = @_;
    my $consdata = $CONSONANTS{ $cons };
    #my $consref = ref $consdata or return $consdata;
    #return $consdata->($position) if $consref eq 'CODE';
    #return $consdata->[$position];
    return ref $consdata ? $consdata->[$position] : $consdata;
}

1;

