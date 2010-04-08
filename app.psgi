use strict;
use Sunaba;
use Sunaba::Runner;
use Plack::Builder;

my $app = Sunaba->webapp;
my $run = Sunaba::Runner->to_app;

my $wrapped = sub {
    my $env = shift;

    if ($env->{HTTP_HOST} eq 'sunaba.plackperl.org') {
        return $app->($env);
    } elsif ($env->{HTTP_HOST} =~ /^([\w\-]+)\.sunaba-app.plackperl\.org/) {
        $env->{'sunaba.app_id'} = $1;
        return $run->($env);
    } else {
        return [ 404, ["Content-Type", "text/plain"], ["Not Found"] ];
    }
};

builder {
    enable "Static", path => sub { s!^/packed/!fatpacked/! };
    $wrapped;
};
