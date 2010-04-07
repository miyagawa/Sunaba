package Sunaba::Runner;
use strict;

# This is not Tatsumaki handler - it's a raw PSGI application

use AnyEvent::HTTP;
use URI::Escape;
use JSON;
use Sunaba::DB;

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
                    or return $respond->([ 404, [], [] ]);

                my $app  = $db->inflate($row);
                my $code = $app->compile_runtime($env);

                http_get "http://api.dan.co.jp/lleval.cgi?c=sunaba&s=" . URI::Escape::uri_escape($code), sub {
                    my($body, $hdr) = @_;
                    my $json = ($body =~ /^sunaba\((.*)\);$/s)[0];
                    if ($json) {
                        my $res = JSON::decode_json($json);
                        $respond->(JSON::decode_json($res->{stdout}));
                    }
                };
            };

            $db->select('app', '*', { id => $id }, $cb);
        };
    };
}

1;