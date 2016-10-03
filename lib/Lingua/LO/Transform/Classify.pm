package Lingua::LO::Transform::Classify;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature qw/ unicode_strings say /;
use charnames qw/ :full lao /;
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Class::Accessor::Fast 'antlers';
use Lingua::LO::Transform::Data;
use Data::Dumper;

=encoding UTF-8

=head1 NAME

Lingua::LO::Transform::Classify - Analyze a Lao syllable and provide accessors to its constituents

=head1 FUNCTION

Objects of this class represent a Lao syllable with an analysis of its
constituents. After passing a valid syllable to the constructor, the parts are
available via accessor methods as outlined below.

=cut

for my $attribute (qw/ syllable parse vowel consonant end_consonant vowel_length tone tone_mark h semivowel /) {
    has $attribute => (is => 'ro');
}

my %TONE_MARKS = (
    ""  => {
        SUNG => 'LOW_RISING',
        KANG => 'LOW',
        TAM  => 'HIGH',
    },
    "\N{LAO TONE MAI EK}" => {
        SUNG => 'MID',
        KANG => 'MID',
        TAM  => 'MID',
    },
    "\N{LAO TONE MAI THO}" => {
        SUNG => 'MID_FALLING',
        KANG => 'HIGH_FALLING',
        TAM  => 'HIGH_FALLING',
    },
    "\N{LAO TONE MAI TI}" => { },  # TODO
    "\N{LAO TONE MAI CATAWA}" => { }   # TODO
);

my %CONSONANTS = (
   ກ  => 'KANG',
   ຂ  => 'SUNG',
   ຄ  => 'TAM',
   ງ  => 'TAM',
   ຈ  => 'KANG',
   ສ  => 'SUNG',
   ຊ  => 'TAM',
   ຍ  => 'TAM',
   ດ  => 'KANG',
   ຕ  => 'KANG',
   ຖ  => 'SUNG',
   ທ  => 'TAM',
   ນ  => 'TAM',
   ບ  => 'KANG',
   ປ  => 'KANG',
   ຜ  => 'SUNG',
   ຝ  => 'SUNG',
   ພ  => 'TAM',
   ຟ  => 'TAM',
   ມ  => 'TAM',
   ຢ  => 'KANG',
   ລ  => 'TAM',
   ວ  => 'TAM',
   ຫ  => 'SUNG',
   ອ  => 'KANG',
   ຮ  => 'TAM',
   ຣ  => 'TAM',
   ຫງ => 'SUNG',
   ຫຍ => 'SUNG',
   ຫນ => 'SUNG',
   ໜ  => 'SUNG',
   ຫມ => 'SUNG',
   ໝ  => 'SUNG',
   ຫລ => 'SUNG',
   ຫຼ  => 'SUNG',
   ຫວ => 'SUNG',
);

my %H_COMBINERS = map { $_ => 1 } qw/ ຍ ວ /;

my %VOWELS = (
    ### Monophthongs
    'Xະ'   => { long => 0 },  # /a/
    'Xັ'    => { long => 0 },  # /a/ with end consonant
    'Xາ'   => { long => 1 },  # /aː/

    'Xິ'    => { long => 0 },  # /i/
    'Xີ'    => { long => 1 },  # /iː/

    'Xຶ'    => { long => 0 },  # /ɯ/
    'Xື'    => { long => 1 },  # /ɯː/

    'Xຸ'    => { long => 0 },  # /u/
    'Xູ'    => { long => 1 },  # /uː/

    'ເXະ'  => { long => 0 },  # /e/
    'ເXັ'   => { long => 0 },  # /e/ with end consonant
    'ເX'   => { long => 1 },  # /eː/

    'ແXະ'  => { long => 0 },  # /ɛ/
    'ແXັ'   => { long => 0 },  # /ɛ/ with end consonant
    'ແX'   => { long => 1 },  # /ɛː/

    'ໂXະ'  => { long => 0 },  # /o/
    'Xົ'    => { long => 0 },  # /o/
    'ໂX'   => { long => 1 },  # /oː/

    'ເXາະ' => { long => 0 },  # /ɔ/
    'Xັອ'   => { long => 0 },  # /ɔ/ with end consonant
    'Xໍ'    => { long => 1 },  # /ɔː/
    'Xອ'   => { long => 1 },  # /ɔː/ with end consonant

    'ເXິ'   => { long => 0 },  # /ɤ/
    'ເXີ'   => { long => 1 },  # /ɤː/

    ###' Diphthongs
    'ເXັຍ'  => { long => 0 },  # /iə/
    'Xັຽ'   => { long => 0 },  # /iə/
    'ເXຍ'  => { long => 1 },  # /iːə/
    'Xຽ'   => { long => 1 },  # /iːə/

    'ເXຶອ'  => { long => 0 },  # /ɯə/
    'ເXືອ'  => { long => 1 },  # /ɯːə/

    'Xົວະ'  => { long => 0 },  # /uə/
    'Xັວ'   => { long => 0 },  # /uə/
    'Xົວ'   => { long => 1 },  # /uːə/
    'Xວ'   => { long => 1 },  # /uːə/ with end consonant

    'ໄX'   => { long => 1 },  # /aj/ - Actually short but counts as long for rules
    'ໃX'   => { long => 1 },  # /aj/ - Actually short but counts as long for rules
    'Xາຍ'  => { long => 1 },  # /aj/ - Actually short but counts as long for rules
    'Xັຍ'   => { long => 0 },  # /aj/

    'ເXົາ'  => { long => 0 },  # /aw/
    'Xໍາ'   => { long => 0 },  # /am/
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

=head1 METHODS

=head2 new

C<new( $syllable )>

The constructor takes a syllable as its only argument. It does not fail but may
produce nonsense if the argument is not valid according to Lao morphology
rules. See L<Lingua::LO::Transform::Syllables/validate> if your input doesn't
come from this class already.

=cut

sub new {
    my ($class, $syllable) = @_;
    return bless _classify($syllable), $class;
}

my $regexp = Lingua::LO::Transform::Data::get_sylre_named;

sub _classify {
   my $s = shift // croak("syllable argument missing");

   $s =~ /^$regexp/ or croak "`$s' does not start with a valid syllable";
   my %class = ( syllable => $s, parse => { %+ } );
   @class{qw/ consonant end_consonant tone_mark semivowel /} = @+{qw/ consonant end_consonant tone_mark semivowel /};

   my @vowels = $+{vowel0} // ();
   push @vowels, "\N{DOTTED CIRCLE}";
   push @vowels, grep { defined } map { $+{"vowel$_"} } 1..3;
   $class{vowel} = join('', @vowels);

   my $v = $VOWELS{ $class{vowel} };
   my $cc = $CONSONANTS{ $class{consonant} };  # consonant category
   if($+{h}) {
       $cc = 'SUNG'; # $CONSONANTS{'ຫ'}

       # If there is a preceding vowel, it uses the ຫ as a consonant and the
       # one parsed as core consonant is actually an end consonant
       unless($H_COMBINERS{ $class{consonant} }) {
           $class{end_consonant} = $class{consonant};
           $class{consonant} = 'ຫ';
       }
       delete $class{h};
   }
   if( $v->{long} ) {
       $class{vowel_length} = 'long';
       $class{tone} = $TONE_MARKS{ $class{tone_mark} // '' }{ $cc };
   } else {
       $class{vowel_length} = 'short';
       $class{tone} = $cc eq 'TAM' ? 'MID_STOP' : 'HIGH_STOP';
   }
   #say Dumper(\%class);
   return \%class;
}

=head2 ACCESSORS


=head3 syllable

The original syllable as passed to the constructor

=head3 parse

A hash of raw constituents as returned by the parsing regexp. Although the
other accessors present constituents in a more accessible way and take care of
morphological special cases like the treatment of ຫ, this may come in handy to
quickly check e.g. if there was a vowel component before the core consonant.

=head3 vowel

The syllable's vowel or diphthong. As the majority of vowels have more than one
code point, the consonant position is represented by the unicode sign
designated for this function, DOTTED CIRCLE or U+25CC.

=head3 consonant

The syllable's core consonant

=head3 end_consonant

The end consonant if present, C<undef> otherwise.

=head3 tone_mark

The tone mark if present, C<undef> otherwise.

=head3 semivowel

The semivowel following the core consonant if present, C<undef> otherwise.

=head3 h

"ຫ" if the syllable contained a combining ຫ, i.e. one that isn't the core consonant.

=head3 vowel_length

The string 'long' or 'short'.

=head3 tone

One of the following strings, depending on core consonant class, vowel length and tone mark:

=over 4

=item LOW_RISING

=item LOW

=item HIGH

=item MID_FALLING

=item HIGH_FALLING

=item MID_STOP

=item HIGH_STOP

=back

The latter two occur with short vowels, the other ones with long vowels.

=cut

1;

