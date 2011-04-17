use Plack::Builder;
use lib 'lib';
use Plack::App::oEmbedProxy;

builder {
  enable "JSONP";
  Plack::App::oEmbedProxy->new->to_app;
}
