package Sunaba::View;
use strict;
use Markapl;

my $layout = sub {
    my $content = shift;

    html {
        head {
            html_link(rel=>'stylesheet', href=>'/static/screen.css');
            title { "Sunaba [BETA]" };
        };
        body {
            div('.container') {
                h1('#title') { a(href=>"/") { "Sunaba" } };
                div('.description') {
                    "Sunaba runs your Plack/PSGI apps on the sandbox cloud.";
                };

                div('.mainbody') {
                    outs_raw $content->();
                    div('#about') {
                        p {
                            outs "Sunaba is an experimental service provided by ";
                            a(href=>'http://bulknews.typepad.com/') { "Tatsuhiko Miyagawa" };
                            outs " on his Linode box. ";
                            outs "Sandbox perl environment is powered by ";
                            a(href=>'http://colabv6.dan.co.jp/lleval.html') { "Dan Kogai's lleval Ajax API." };
                            outs " All services can be shutdown at any time at their own will. NO WARRANTY. Use at your own risk.";
                        }
                    }
                }
            }
        }
    };
};

template 'index' => sub {
    my $skelton_app = <<APP;
my \$app = sub {
    [ 200, [ "Content-Type", "text/plain" ], [ "Hello World" ] ];
};
APP

    my $content = form(action => '/create', method=>'post') {
        textarea(class=>'create',rows=>24, cols=>80,name=>'code') { $skelton_app };
        div('#run') { input(type=>'submit', value=>'Run your code') {} };
    };

    $layout->($content);
};

template 'app' => sub {
    my($class, $stash) = @_;

    my $app = $stash->{app};

    my $content = div('#app') {
        p('.link') {
            outs "Yay, this app is now running on ";
            a(href=>$app->url, target=>"_blank") { $app->url };
        };

        form(action => '/app/' . $app->id, method=>'post') {
            textarea(class=>'view',rows=>24, cols=>80,name=>'code') { $app->code };
            if ($app->can_edit($stash->{handler}->request)) {
                div('#run') {
                    input(type=>'submit', value=>'Update your code');
                    input(type=>'submit', name =>'clone', value=>'Clone');
                };
            } else {
                div('#run') {
                    input(type=>'submit', name =>'clone', value=>'Clone');
                }
            }
        }
    };

    $layout->($content, $stash);
};

1;
