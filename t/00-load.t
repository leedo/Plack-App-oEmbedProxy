#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Plack::App::oEmbedProxy' ) || print "Bail out!
";
}

diag( "Testing Plack::App::oEmbedProxy $Plack::App::oEmbedProxy::VERSION, Perl $], $^X" );
