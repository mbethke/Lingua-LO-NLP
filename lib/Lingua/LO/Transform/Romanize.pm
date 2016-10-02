package Lingua::LO::Transform::Romanize;
use strict;
use warnings;
use 5.012000;
use utf8;
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Lingua::LO::Transform::Syllables;

sub new {
    my ($class, %args) = @_;
    my $variant = delete $args{variant} or confess("`variant' arg missing");
    my $hyphenate = delete $args{hyphenate};

    my $subclass = __PACKAGE__ . "::$variant";
    (my $module = $subclass) =~ s!::!/!g;
    require "$module.pm";

    my $self = $subclass->new(%args);
    $self->{hyphenate} = $hyphenate;
    return $self;
}

sub romanize {
    my ($self, $text) = @_;
    my $result = '';
    my $sep_char = $self->{hyphenate} ? '-' : ' ';

    my @frags = Lingua::LO::Transform::Syllables->new( text => $text )->get_fragments;
    while(@frags) {
        my @lao;
        push @lao, shift @frags while @frags and $frags[0]->{is_lao};
        $result .= join($sep_char, map { $self->romanize_syllable( $_->{text} ) } @lao);
        $result .= (shift @frags)->{text} while @frags and not $frags[0]->{is_lao};
    }
    return $result;
}

1;

