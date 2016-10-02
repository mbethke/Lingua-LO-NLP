package Lingua::LO::Transform::Romanize::PCGN;
use strict;
use warnings;
use 5.012000;
use utf8;
use feature qw/ unicode_strings say /;
use charnames qw/ :full lao /;
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Lingua::LO::Transform::Classify;
use parent 'Lingua::LO::Transform::Romanize';

=encoding utf-8

=cut

my %CONSONANTS = (
   ກ  => 'k',
   ຂ  => 'kh',
   ຄ  => 'kh',
   ງ  => 'ng',
   ຈ  => 'ch',
   ສ  => 's',
   ຊ  => 'x',
   ຍ  => [qw/ gn y /],
   ດ  => [qw/ d t /],
   ຕ  => 't',
   ຖ  => 'th',
   ທ  => 'th',
   ນ  => 'n',
   ບ  => [qw/ b p /],
   ປ  => 'p',
   ຜ  => 'ph',
   ຝ  => 'f',
   ພ  => 'ph',
   ຟ  => 'f',
   ມ  => 'm',
   ຢ  => 'y',
   ລ  => 'l',
   "\N{LAO SEMIVOWEL SIGN LO}"  => 'l',
   ວ  => [qw/ v o /],
   ຫ  => \&ຫ,
   ອ  => '',
   ຮ  => 'h',
   ຣ  => 'r',
   ໜ  => 'n',
   ໝ  => 'm',
   ຫຼ  => 'l',
   ຫຍ => 'gn',
   ຫນ => 'n',
   ຫມ => 'm',
   ຫຣ => 'r',
   ຫລ => 'l',
   ຫວ => 'v',
);

sub ຫ {
    my ($c, $pos) = @_;
    return 'h' unless $pos; # initial position
    die "unhandled ຫ";  # TODO: can't happen?
}

my %CONS_VOWELS = map { $_ => 1 } qw/ ຍ ຽ ອ ວ /;

my %VOWELS = (
    ### Monophthongs
    'Xະ'   => 'a',
    'Xັ'    => 'a',
    'Xາ'   => 'a',
    'Xາວ'  => 'ao',

    'Xິ'    => 'i',
    'Xີ'    => 'i',

    'Xຶ'    => 'u',
    'Xື'    => 'u',

    'Xຸ'    => 'ou',
    'Xູ'    => 'ou',

    'ເXະ'  => 'é',
    'ເXັ'   => 'é',
    'ເX'   => 'é',

    'ແXະ'  => 'è',
    'ແXັ'   => 'è',
    'ແX'   => 'è',
    'ແXວ'  => 'èo',

    'ໂXະ'  => 'ô',
    'Xົ'    => 'ô',
    'ໂX'   => 'ô',
    'ໂXຍ'  => 'ôy', # TODO correct?

    'ເXາະ' => 'o',
    'Xັອ'   => 'o',
    'Xໍ'    => 'o',
    'Xອ'   => 'o',

    'ເXິ'   => 'eu',
    'ເXີ'   => 'eu',
    'ເXື'   => 'eu', # TODO correct?

    'ເXັຍ'  => 'ia',  # /iə/
    'Xັຽ'   => 'ia',  # /iə/
    'ເXຍ'  => 'ia',  # /iːə/
    'Xຽ'   => 'ia',  # /iːə/
    'Xຽວ'  => 'iao',

    'ເXຶອ'  => 'ua',
    'ເXືອ'  => 'ua',

    'Xົວະ'  => 'oua',
    'Xັວ '  => 'oua',
    'Xົວ'   => 'oua',
    'Xວ'   => 'oua',
    'Xວຍ'  => 'ouai',

    'ໄX'   => 'ai',
    'ໃX'   => 'ai',
    'Xາຍ'  => 'ay',  # /aj/ - Actually short but counts as long for rules
    'Xັຍ'   => 'ay',  # /aj/

    'ເXົາ'  => 'ao',
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

sub new {
    my $class = shift;
    # Not calling SUPER::new on purpose!
    return bless {}, $class;
}

sub romanize_syllable {
    my ($self, $syllable) = @_;
    my ($consonant, $endcons, $result);
    my $c = Lingua::LO::Transform::Classify->new($syllable);
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

    $result .= $VOWELS{ $vowel } . $endcons;
    $result .= "-$result" if defined $parse->{extra}  and $parse->{extra} eq 'ໆ';  # duplication sign
    return $result;
}

sub _consonant {
    my ($cons, $position) = @_;
    my $consdata = $CONSONANTS{ $cons };
    my $consref = ref $consdata or return $consdata;
    return $consdata->($position) if $consref eq 'CODE';
    return $consdata->[$position];
}

1;

