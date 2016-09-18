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
use Data::Dumper;
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
    die "unhandled ຫ";
}

my %CONS_VOWELS = map { $_ => 1 } qw/ ຍ ຽ ອ /;

my %VOWELS = (
    ### Monophthongs
    'Xະ'   => 'a',
    'XັX'   => 'a',
    'Xາ'   => 'a',

    'Xິ'    => 'i',
    'Xີ'    => 'i',

    'Xຶ'    => 'u',
    'Xື'    => 'u',

    'Xຸ'    => 'ou',
    'Xູ'    => 'ou',

    'ເXະ'  => 'é',
    'ເXັX'  => 'é',
    'ເX'   => 'é',

    'ແXະ'  => 'è',
    'ແXັX'  => 'è',
    'ແX'   => 'è',

    'ໂXະ'  => 'ô',
    'Xົ'    => 'ô',
    'ໂX'   => 'ô',

    'ເXາະ' => 'o',
    'XັອX'  => 'o',
    'Xໍ'    => 'o',
    'XອX'  => 'o',

    'ເXິ'   => 'eu',
    'ເXີ'   => 'eu',
    'ເXື'   => 'eu', # TODO new?

    'ເXັຍ'  => 'ia',  # /iə/
    'Xັຽ'   => 'ia',  # /iə/
    'ເXຍ'  => 'ia',  # /iːə/
    'Xຽ'   => 'ia',  # /iːə/

    'ເXຶອ'  => 'ua',
    'ເXືອ'  => 'ua',

    'Xົວະ'  => 'oua',
    'XັວX'  => 'oua',
    'Xົວ'   => 'oua',
    'XວX'  => 'oua',

    'ໄX'   => 'ai',
    'ໃX'   => 'ai',
    'Xາຍ'  => 'ay',  # /aj/ - Actually short but counts as long for rules
    'Xັຍ'   => 'ay',  # /aj/

    'ເXົາ'  => 'ao',
    'Xໍາ'   => 'am',
);

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub romanize_syllable {
    my ($self, $syllable) = @_;
    my ($consonant, $endcons, $result);
    my $c = Lingua::LO::Transform::Classify->new($syllable);
    my $parse = $c->parse;
    my $vowel = $c->vowel;
    
    if($c->h and $c->parse->{vowel0}) {
        # ຫ with preceding vowel
        $result = _consonant('ຫ', 0);
        $endcons = $c->consonant;
        die "Unhandled parse: ".Dumper($c->parse) if $c->end_consonant;
    } else {
        $result = _consonant($c->consonant, 0);
        $endcons = $c->end_consonant;
    }

    if(defined $endcons) {
        if(exists $CONS_VOWELS{ $endcons }) {
            $vowel =~ s/X$/$endcons/;   # consonant can be used as a vowel
            $endcons = '';
        } else {
            $endcons = _consonant($endcons, 1);
        }
    } else {
        $endcons = '';  # avoid special-casing later
    }

    warn "VOWEL: $vowel\n";
    warn "ENDCONS: $endcons\n" if $endcons;
    $result .= $VOWELS{ $vowel } . $endcons;
    print Dumper($parse);
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


