package Lingua::LO::Transform::Romanize;
use strict;
use warnings;
use 5.012000;
use utf8;
use version 0.77; our $VERSION = version->declare('v0.0.1');
use Carp;
use Lingua::LO::Transform::Syllables;

=encoding UTF-8

=head1 NAME

Lingua::LO::Transform::Romanize - Romanize Lao syllables

=head1 FUNCTION

This s a factory class for Lingua::LO::Transform::Romanize::*. Currently there
is only L<Lingua::LO::Transform::Romanize::PCGN> but other variants are
planned.

=head1 SYNOPSIS

    my $o = Lingua::LO::Transform::Romanize->new(
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

=cut

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

=head2 romanize

    romanize($text)

Return the romanization of C<$text> according to the standard passed to the
constructor. Lao syllables will be processed and everything else is passed
through unchanged save for possible conversion of combining characters to a
canonically equivalent form in L<Unicode::Normalize/NFC>.

=cut

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

