package Sunaba::Runner;
use strict;

# This is not Tatsumaki handler - it's a raw PSGI application

use AnyEvent::HTTP;
use URI::Escape;
use JSON;
use Sunaba::DB;
use Storable;
use MIME::Base64;

sub to_app {
    return sub {
        my $env = shift;
        return sub {
            my $respond = shift;

            my $id = $env->{'sunaba.app_id'}
                or return $respond->([ 404, [ "Content-Type", "text/plain" ], [ "Not Found" ] ]);

            my $db = Sunaba::DB->new;
            my $cb = sub {
                my($dbh, $rows, $rv) = @_;
                my $row = $rows->[0]
                    or return $respond->([ 404, [ "Content-Type", "text/plain" ], [ "Not Found" ] ]);

                my $app  = $db->inflate($row);
                my $code = $app->compile_runtime($env);
                my $uri  = "http://api.dan.co.jp/lleval.cgi?c=sunaba&s=" . URI::Escape::uri_escape($code);

                my $hdrs = {
                    'User-Agent' => "Sunaba/$Sunaba::VERSION",
                    'X-Forwarded-For' => $env->{REMOTE_ADDR},
                };

                http_get $uri, headers => $hdrs, sub {
                    my($body, $hdr) = @_;
                    my $json = ($body =~ /^sunaba\((.*)\);$/s)[0];
                    if ($json) {
                        my $res = JSON::from_json($json);
                        if ($res->{status} == 65280) {
                            $respond->([ 500, [ "Content-Type", "text/plain" ], [ $res->{stderr} ] ]);
                        } elsif ($res->{error}) {
                            $respond->([ 500, [ "Content-Type", "text/plain" ], [ $res->{error} ] ]);
                        } else {
                            $respond->(Storable::thaw(MIME::Base64::decode_base64($res->{stdout})));
                        }
                    }
                };
            };

            $db->select('app', '*', { id => $id }, $cb);
        };
    };
}

1;
