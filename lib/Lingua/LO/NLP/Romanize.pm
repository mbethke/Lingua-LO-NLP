package Lingua::LO::NLP::Romanize;
use strict;
use warnings;
use 5.012000;
use utf8;
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Scalar::Util 'blessed';
use Lingua::LO::NLP::Syllabify;

=encoding UTF-8

=head1 NAME

Lingua::LO::NLP::Romanize - Romanize Lao syllables

=head1 FUNCTION

This s a factory class for Lingua::LO::NLP::Romanize::*. Currently there
is only L<Lingua::LO::NLP::Romanize::PCGN> but other variants are
planned.

=head1 SYNOPSIS

    my $o = Lingua::LO::NLP::Romanize->new(
        variant => 'PCGN',
        hyphenate => 1,
    );

=cut

=head1 METHODS

=head2 new

See L</SYNOPSIS> on how to use the constructor. Arguments supported are:

=over 4

=item C<variant>: standard according to which to romanize. "PCGN" is the only
one currently implemented.

=item C<hyphenate>: separate runs of Lao syllables with hyphens if true.
Otherwise, blanks are used.

=back

=cut

sub new {
    my ($class, %args) = @_;

    # Allow subclasses to omit a constructor
    return bless {}, $class if $class ne __PACKAGE__;

    # If we've been called on Lingua::LO::NLP::Romanize, require a variant
    my $variant = delete $args{variant} or confess("`variant' arg missing");
    my $hyphenate = delete $args{hyphenate};

    my $subclass = __PACKAGE__ . "::$variant";
    (my $module = $subclass) =~ s!::!/!g;
    require "$module.pm";

    my $self = $subclass->new(%args);
    $self->{hyphenate} = $hyphenate;
    return $self;
}

=head2 romanize

    romanize( $text )

Return the romanization of C<$text> according to the standard passed to the
constructor. Text is split up by
L<Lingua::LO::NLP::Syllabify/get_fragments>; Lao syllables are processed
and everything else is passed through unchanged save for possible conversion of
combining characters to a canonically equivalent form in
L<Unicode::Normalize/NFC>.

=cut

sub romanize {
    my ($self, $text) = @_;
    my $result = '';
    my $sep_char = $self->{hyphenate} ? '-' : ' ';

    my @frags = Lingua::LO::NLP::Syllabify->new( text => $text )->get_fragments;
    while(@frags) {
        my @lao;
        push @lao, shift @frags while @frags and $frags[0]->{is_lao};
        $result .= join($sep_char, map { $self->romanize_syllable( $_->{text} ) } @lao);
        $result .= (shift @frags)->{text} while @frags and not $frags[0]->{is_lao};
    }
    return $result;
}

=head2 romanize_syllable

    romanize_syllable( $syllable )

Return the romanization of a single C<$syllable> according to the standard passed to the
constructor. This is a virtual method that must be implemented by subclasses.

=cut

sub romanize_syllable {
    my $self = shift;
    ref $self or die "romanize_syllable is not a class method";
    die blessed($self) . " must implement romanize_syllable()";
}

1;

