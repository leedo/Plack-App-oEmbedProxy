package Plack::App::oEmbedProxy;

use warnings;
use strict;

our $VERSION = '0.01';

use Any::Moose;
use AnyEvent::HTTP;
use Plack::Request;
use Web::oEmbed;
use CHI;

use parent 'Plack::Component';

has oembed => (
  is => 'rw',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $consumer = Web::oEmbed->new({format => $self->format});
    for my $provider (@{ $self->providers }) {
      $consumer->register_provider({
        url => $provider->[0],
        api => $provider->[1],
      });
    }
    return $consumer;
 }
);

has providers => (
  is => 'rw',
  default => sub {[
    ['http://*.youtube.com/*', 'http://www.youtube.com/oembed/'],
    ['http://*.flickr.com/*', 'http://www.flickr.com/services/oembed/'],
    ['http://*viddler.com/*', 'http://lab.viddler.com/services/oembed/'],
    ['http://qik.com/video/*', 'http://qik.com/api/oembed.{format}'],
    ['http://www.hulu.com/watch/*', 'http://www.hulu.com/api/oembed.{format}'],
    ['http://www.vimeo.com/*', 'http://www.vimeo.com/api/oembed.{format}'],
  ]}
);

has cache => (
  is => 'ro',
  lazy => 1,
  default => sub {
    my $self = shift;
    CHI->new(driver => 'File', root_dir => $self->cache_root);
  }
);

has cache_root => (
  is => 'ro',
  required => 1,
  default => './cache'
);

has format => (
  is => 'rw',
  default => "json",
);

has maxwidth => (is => 'rw');
has maxheight => (is => 'rw');

sub call {
  my ($self, $env) = @_;
  my $req = Plack::Request->new($env);

  if (my $url = $req->parameters->{url}) {

    if (my $res = $self->cache->get($url)) {
      return $res;
    }

    elsif (my $service = $self->request_url($url)) {
      return sub {
        my $respond = shift;
        http_request "get", $service, sub {
          my ($body, $headers) = @_;
          if ($headers->{Status} == 200) {
            my $res = [200, ["Content-Type", $headers->{"content-type"}], [$body]];
            $self->cache->set($url, $res);
            $respond->($res);
          }
          $respond->([404, ["Content-Type", "text/plain"], ["not found"]]);
        };
      };
    }
  }

  return [404, ['Content-Type', 'text/plain'], ['not found']];
}

sub request_url {
  my ($self, $url) = @_;

  my $opts = {format => $self->format};

  $opts->{maxwidth}  = $self->maxwidth  if defined $self->maxwidth;
  $opts->{maxheight} = $self->maxheight if defined $self->maxheight;

  return $self->oembed->request_url($url, $opts);
}

1;
