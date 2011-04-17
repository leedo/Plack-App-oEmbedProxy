package Plack::App::oEmbedProxy;

use warnings;
use strict;

our $VERSION = '0.01';

use AnyEvent::HTTP;
use Plack::Request;
use Web::oEmbed;
use CHI;
use Plack::Util::Accessor qw/providers cache_root format maxwidth maxheight/;

use parent 'Plack::Component';

sub prepare_app {
  my $self = shift;

  $self->providers($self->_default_providers) unless defined $self->providers;
  $self->cache_root("./cache")                unless defined $self->cache_root;
  $self->format("json")                       unless defined $self->format;
  $self->maxwidth(300)                        unless defined $self->maxwidth;
  $self->maxheight(300)                       unless defined $self->maxheight;

  $self->{oembed} = Web::oEmbed->new({format => $self->format});
  $self->{cache} =  CHI->new(driver => 'File', root_dir => $self->cache_root);

  for my $provider (@{ $self->providers }) {
    $self->{oembed}->register_provider({
      url => $provider->[0],
      api => $provider->[1],
    });
  }
}

sub _default_providers {
  [
    ['http://*.youtube.com/*', 'http://www.youtube.com/oembed/'],
    ['http://*.flickr.com/*', 'http://www.flickr.com/services/oembed/'],
    ['http://*viddler.com/*', 'http://lab.viddler.com/services/oembed/'],
    ['http://qik.com/video/*', 'http://qik.com/api/oembed.{format}'],
    ['http://www.hulu.com/watch/*', 'http://www.hulu.com/api/oembed.{format}'],
    ['http://www.vimeo.com/*', 'http://www.vimeo.com/api/oembed.{format}'],
  ];
}

sub call {
  my ($self, $env) = @_;
  my $req = Plack::Request->new($env);

  if (my $url = $req->parameters->{url}) {

    if (my $res = $self->{cache}->get($url)) {
      return $res;
    }

    elsif (my $service = $self->request_url($url, $req->parameters)) {
      return sub {
        my $respond = shift;
        http_request "get", $service, sub {
          my ($body, $headers) = @_;
          if ($headers->{Status} == 200) {
            my $res = [200, ["Content-Type", $headers->{"content-type"}], [$body]];
            $self->{cache}->set($url, $res);
            $respond->($res);
          }
          else {
            $respond->([404, ["Content-Type", "text/plain"], ["not found"]]);
          }
        };
      };
    }
  }

  return [404, ['Content-Type', 'text/plain'], ['not found']];
}

sub request_url {
  my ($self, $url, $parameters) = @_;

  my $opts = {
    format    => $parameters->{format}    || $self->format    || "json",
    maxwidth  => $parameters->{maxwidth}  || $self->maxwidth  || 300,
    maxheight => $parameters->{maxheight} || $self->maxheight || 300,
  };

  return $self->{oembed}->request_url($url, $opts);
}

1;
