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
    my $variant = delete $args{variant} or croak("`variant' arg missing");
    my $subclass = __PACKAGE__ . "::$variant";
    (my $module = $subclass) =~ s!::!/!g;
    require "$module.pm";
    return $subclass->new(%args);
}

sub romanize {
    my ($self, $text) = @_;

    my $splitter = Lingua::LO::Transform::Syllables->new( text => $text );
    return join('-',
        map { $self->romanize_syllable($_) } $splitter->get_syllables
    );
}

1;

