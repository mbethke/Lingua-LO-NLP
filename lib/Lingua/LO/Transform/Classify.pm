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
use Lingua::LO::Transform::Regexp;
use Data::Dumper;

for my $attribute (qw/ syllable parse vowel consonant end_consonant vowel_length tone tone_mark h semivowel /) {
    has $attribute => (is => 'ro');
}

my %TONE_MARKS = (
    ""  => {
        AKSON_SUNG => 'LOW_RISING',
        AKSON_KANG => 'LOW',
        AKSON_TAM  => 'HIGH',
    },
    "\N{LAO TONE MAI EK}" => {
        AKSON_SUNG => 'MID',
        AKSON_KANG => 'MID',
        AKSON_TAM  => 'MID',
    },
    "\N{LAO TONE MAI THO}" => {
        AKSON_SUNG => 'MID_FALLING',
        AKSON_KANG => 'HIGH_FALLING',
        AKSON_TAM  => 'HIGH_FALLING',
    },
    "\N{LAO TONE MAI TI}" => { },  # TODO
    "\N{LAO TONE MAI CATAWA}" => { }   # TODO
);

my %CONSONANTS = (
   ກ  => { cat => 'AKSON_KANG' },
   ຂ  => { cat => 'AKSON_SUNG' },
   ຄ  => { cat => 'AKSON_TAM' },
   ງ  => { cat => 'AKSON_TAM' },
   ຈ  => { cat => 'AKSON_KANG' },
   ສ  => { cat => 'AKSON_SUNG' },
   ຊ  => { cat => 'AKSON_TAM' },
   ຍ  => { cat => 'AKSON_TAM' },
   ດ  => { cat => 'AKSON_KANG' },
   ຕ  => { cat => 'AKSON_KANG' },
   ຖ  => { cat => 'AKSON_SUNG' },
   ທ  => { cat => 'AKSON_TAM' },
   ນ  => { cat => 'AKSON_TAM' },
   ບ  => { cat => 'AKSON_KANG' },
   ປ  => { cat => 'AKSON_KANG' },
   ຜ  => { cat => 'AKSON_SUNG' },
   ຝ  => { cat => 'AKSON_SUNG' },
   ພ  => { cat => 'AKSON_TAM' },
   ຟ  => { cat => 'AKSON_TAM' },
   ມ  => { cat => 'AKSON_TAM' },
   ຢ  => { cat => 'AKSON_KANG' },
   ລ  => { cat => 'AKSON_TAM' },
   ວ  => { cat => 'AKSON_TAM' },
   ຫ  => { cat => 'AKSON_SUNG' },
   ອ  => { cat => 'AKSON_KANG' },
   ຮ  => { cat => 'AKSON_TAM' },
   ຣ  => { cat => 'AKSON_TAM' },
   ຫງ => { cat => 'AKSON_SUNG' },
   ຫຍ => { cat => 'AKSON_SUNG' },
   ຫນ => { cat => 'AKSON_SUNG' },
   ໜ  => { cat => 'AKSON_SUNG' },
   ຫມ => { cat => 'AKSON_SUNG' },
   ໝ  => { cat => 'AKSON_SUNG' },
   ຫລ => { cat => 'AKSON_SUNG' },
   ຫຼ  => { cat => 'AKSON_SUNG' },
   ຫວ => { cat => 'AKSON_SUNG' },
);

my %H_COMBINERS = map { $_ => 1 } qw/ ງ ຍ ວ /;

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

sub new {
    my ($class, $syllable) = @_;
    return bless $class->SUPER::new( _classify($syllable) ), $class;
}

my $regexp = Lingua::LO::Transform::Regexp::syllable_named;
say $regexp if $ENV{DEBUG};

sub _classify {
   my $s = shift // croak("syllable argument missing");

   $s =~ /^$regexp/ or croak "`$s' does not start with a valid syllable";
   my %class = ( syllable => $s, parse => { %+ } );
   @class{qw/ consonant end_consonant tone_mark semivowel /} = @+{qw/ consonant end_consonant tone_mark semivowel /};

   my @vowels = $+{vowel0} // ();
   push @vowels, 'X';
   push @vowels, grep { defined } map { $+{"vowel$_"} } 1..3;
   #push @vowels, 'X' if defined $+{end_consonant};
   $class{vowel} = join('', @vowels);

   my $v = $VOWELS{ $class{vowel} };
   my $cc = $CONSONANTS{ $class{consonant} }{cat};  # consonant category
   if($+{h}) {
       if(exists $H_COMBINERS{ $class{consonant} }) {
           # The consonant combines with ຫ to chnage the tone class
           $cc = 'AKSON_SUNG';
       } else {
           # If there is a preceding vowel, it combines with the h and the
           # consonant is actually an end consonant
           if(defined $+{vowel0}) {
               $class{end_consonant} = $class{consonant};
               $class{consonant} = 'ຫ';
               $cc = 'AKSON_SUNG'; # $CONSONANTS{'ຫ'}{cat}
               delete $class{h};
           } else {
               die "Unhandled h-combination: ຫ$class{consonant}.\n".Dumper(\%+);
           }
       }
   }
   if( $v->{long} ) {
       $class{vowel_length} = 'long';
       $class{tone} = $TONE_MARKS{ $class{tone_mark} // '' }{ $cc };
   } else {
       $class{vowel_length} = 'short';
       $class{tone} = $cc eq 'AKSON_TAM' ? 'MID_STOP' : 'HIGH_STOP';
   }
   #say Dumper(\%class);
   return \%class;
}

1;

