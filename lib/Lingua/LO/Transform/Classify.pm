package Lingua::LO::Transform::Classify;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature qw/ unicode_strings say /;
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Class::Accessor::Fast 'antlers';
use Lingua::LO::Transform::Regexp;
use Carp;
use Data::Dumper;

has syllable => (is => 'ro');
has vowel => (is => 'ro');
has consonant => (is => 'ro');
has vowel_length => (is => 'ro');
has tone => (is => 'ro');
has tone_mark => (is => 'ro');

my %TONE_MARKS = (
    ""  => {
        AKSON_SUNG => 'TONE_LOW_RISING',
        AKSON_KANG => 'TONE_LOW',
        AKSON_TAM  => 'TONE_HIGH',
    },
    "\x{0ec8}" => {
        AKSON_SUNG => 'TONE_MID',
        AKSON_KANG => 'TONE_MID',
        AKSON_TAM  => 'TONE_MID',
    },
    "\x{0ec9}" => {
        AKSON_SUNG => 'TONE_MID_FALLING',
        AKSON_KANG => 'TONE_HIGH_FALLING',
        AKSON_TAM  => 'TONE_HIGH_FALLING',
    },
    "\x{0eca}" => { },  # TODO
    "\x{0ecb}" => { }   # TODO
);
my $TONE_CHARCLASS = '[' . join('', sort keys %TONE_MARKS) . ']';

my %CONSONANTS = (
   ກ  => { cat => 'AKSON_KANG', end => 'END_NOTONE' },
   ຂ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຄ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ງ  => { cat => 'AKSON_TAM',  end => 'END_TONE' },
   ຈ  => { cat => 'AKSON_KANG', end => 'END_NO' },
   ສ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຊ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ຍ  => { cat => 'AKSON_TAM',  end => 'END_TONE' },
   ດ  => { cat => 'AKSON_KANG', end => 'END_NOTONE' },
   ຕ  => { cat => 'AKSON_KANG', end => 'END_NO' },
   ຖ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ທ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ນ  => { cat => 'AKSON_TAM',  end => 'END_TONE' },
   ບ  => { cat => 'AKSON_KANG', end => 'END_NOTONE' },
   ປ  => { cat => 'AKSON_KANG', end => 'END_NO' },
   ຜ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຝ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ພ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ຟ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ມ  => { cat => 'AKSON_TAM',  end => 'END_TONE' },
   ຢ  => { cat => 'AKSON_KANG', end => 'END_NO' },
   ລ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ວ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ຫ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ອ  => { cat => 'AKSON_KANG', end => 'END_NO' },
   ຮ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ຣ  => { cat => 'AKSON_TAM',  end => 'END_NO' },
   ຫງ => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຫຍ => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຫນ => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ໜ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຫມ => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ໝ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຫລ => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຫຼ  => { cat => 'AKSON_SUNG', end => 'END_NO' },
   ຫວ => { cat => 'AKSON_SUNG', end => 'END_NO' },
);

my %VOWELS = (
    ### Monophthongs
    'Xະ'   => { long => 0 },  # /a/
    'XັX'   => { long => 0 },  # /a/ with end consonant
    'Xາ'   => { long => 1 },  # /aː/

    'Xິ'    => { long => 0 },  # /i/
    'Xີ'    => { long => 1 },  # /iː/

    'Xຶ'    => { long => 0 },  # /ɯ/
    'Xື'    => { long => 1 },  # /ɯː/

    'Xຸ'    => { long => 0 },  # /u/
    'Xູ'    => { long => 1 },  # /uː/

    'ເXະ'  => { long => 0 },  # /e/
    'ເXັX'  => { long => 0 },  # /e/ with end consonant
    'ເX'   => { long => 1 },  # /eː/

    'ແXະ'  => { long => 0 },  # /ɛ/
    'ແXັX'  => { long => 0 },  # /ɛ/ with end consonant
    'ແX'   => { long => 1 },  # /ɛː/

    'ໂXະ'  => { long => 0 },  # /o/
    'Xົ'    => { long => 0 },  # /o/
    'ໂX'   => { long => 1 },  # /oː/

    'ເXາະ' => { long => 0 },  # /ɔ/
    'XັອX'  => { long => 0 },  # /ɔ/ with end consonant
    'Xໍ'    => { long => 1 },  # /ɔː/
    'XອX'  => { long => 1 },  # /ɔː/ with end consonant

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
    'XັວX'  => { long => 0 },  # /uə/
    'Xົວ'   => { long => 1 },  # /uːə/
    'XວX'  => { long => 1 },  # /uːə/ with end consonant

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
   @class{qw/ consonant end_consonant tone_mark /} = @+{qw/ consonant end_consonant tone_mark /};

   my @vowels = $+{vowel0} // ();
   push @vowels, 'X';
   push @vowels, grep { defined } map { $+{"vowel$_"} } 1..3;
   push @vowels, 'X' if defined $+{end_consonant};
   $class{vowel} = join('', @vowels);

   #say Dumper($class{vowel});
   my $v = $VOWELS{ $class{vowel} };
   my $cc = $CONSONANTS{ $class{consonant} }{cat};  # consonant category
   if( $v->{long} ) {
       $class{vowel_length} = 'long';
       $class{tone} = $TONE_MARKS{ $class{tone_mark} // '' }{ $cc };
   } else {
       $class{vowel_length} = 'short';
       $class{tone} = $cc eq 'AKSON_TAM' ? 'TONE_MID_STOP' : 'TONE_HIGH_STOP';
   }
   return \%class;
}

1;

