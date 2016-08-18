package Lingua::LO::Transform::Classify;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature 'unicode_strings';
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Class::Accessor::Fast 'antlers';

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
my $CONSONANT_RE = join(
    '|',
    reverse
    sort { length($a) <=> length($b) }
    keys %CONSONANTS
);

my %VOWELS = (
    Xະ   => { long => 0 },
    Xາ   => { long => 1 },
    Xັ    => { long => 0 },
    Xົ    => { long => 0 },
    Xິ    => { long => 0 },
    Xີ    => { long => 1 },
    Xຶ    => { long => 0 },
    Xື    => { long => 1 },
    Xຸ    => { long => 0 },
    Xູ    => { long => 1 },
    ເXະ  => { long => 0 },
    ເX   => { long => 1 },
    ແXະ  => { long => 0 },
    ແX   => { long => 1 },
    ໂXະ  => { long => 0 },
    ໂX   => { long => 1 },
    ເXາະ => { long => 0 },
    Xໍ    => { long => 1 },
    ເXິ   => { long => 0 },
    ເXີ   => { long => 1 },
    ເXັຍ  => { long => 0 },
    ເXຍ  => { long => 1 },
    ເXຶອ  => { long => 0 },
    ເXືອ  => { long => 1 },
    Xົວະ  => { long => 0 },
    Xວ   => { long => 1 },
    Xົວ   => { long => 1 },  # TODO
    ໄX   => { long => 1 },
    ໃX   => { long => 1 },
    ເXົາ  => { long => 1 },  # TODO
    Xໍາ   => { long => 0 },  # TODO
    ເXັ   => { long => 0 },  # TODO
    Xອ   => { long => 1 },

);
my %VOWELS_NOCONS = map {
    my $v = $_;
    s/X//;
    $_ => $VOWELS{$v}
} sort keys %VOWELS;

($VOWELS{$_}{re} = $_) =~ s/X/(?:$CONSONANT_RE)$TONE_CHARCLASS?/ for sort keys %VOWELS; # add vowel regexp

my $EXTRACT_RE = sprintf(
    '((?:%s))',
    join(
        '|',
        reverse
        sort { length($a) <=> length($b) }
        map { $VOWELS{$_}{re} }
        keys %VOWELS
    )
);

sub foo { shift->vowel_length }

sub new {
    my ($class, $syllable) = @_;
    return bless $class->SUPER::new( _classify($syllable) ), $class;
}

sub _classify {
   my $s = shift // croak("syllable argument missing");
   my %class = ( syllable => $s );
   #print "Matching: $EXTRACT_RE\n";
   croak "malformed syllable $s" unless $s =~ /^$EXTRACT_RE/o;
   #print "Matching: $CONSONANT_RE\n";

   my ($c) = $s =~ /($CONSONANT_RE)/;
   $class{consonant} = $c;

   my ($t) = $s =~ /($TONE_CHARCLASS)/;
   $class{tone_mark} = $t //= '';

   $s =~ s/$c//;
   $s =~ s/(?:$CONSONANT_RE)$//;
   $s =~ s/$TONE_CHARCLASS//;

   $class{vowel} = $s;

   my $v = $VOWELS_NOCONS{$s};
   if($v->{long}) {
       $class{vowel_length} = 'long';
       $class{tone} = $TONE_MARKS{$t}{ $CONSONANTS{$c}{cat} };
   } else {
       $class{vowel_length} = 'short';
       $class{tone} = $CONSONANTS{$c}{cat} eq 'AKSON_TAM' ?
       'TONE_MID_STOP' : 'TONE_HIGH_STOP';
   }

   return \%class;
}

1;

