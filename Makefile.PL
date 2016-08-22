use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Lingua::LO::Transform',
    VERSION_FROM => 'lib/Lingua/LO/Transform.pm',
    AUTHOR       => 'Matthias Bethke <mbethke@cpan.org>',
    ABSTRACT     => 'Various transformations for Lao text',
    MIN_PERL_VERSION => '5.012000',
    PREREQ_PM    => {
        version => 0.77,
        Carp    => 0,
        charnames => 0,
        'Unicode::Normalize' => 0,
        'Class::Accessor::Fast' => 0,
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
    },
);
