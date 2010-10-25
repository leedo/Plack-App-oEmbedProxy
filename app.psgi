use Plack::Builder;
use lib 'lib';
use Plack::App::oEmbedProxy;

Plack::App::oEmbedProxy->new->to_app;
