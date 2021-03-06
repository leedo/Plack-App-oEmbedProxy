use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Plack::App::oEmbedProxy',
    AUTHOR              => q{Lee Aylward <leedo@cpan.org>},
    VERSION_FROM        => 'lib/Plack/App/oEmbedProxy.pm',
    ABSTRACT_FROM       => 'lib/Plack/App/oEmbedProxy.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Plack-App-oEmbedProxy-*' },
);
