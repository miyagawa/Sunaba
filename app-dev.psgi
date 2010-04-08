use strict;
use Sunaba;
use Sunaba::Runner;
use Plack::Builder;

$ENV{SUNABA_DEV} = 1;

my $app = Sunaba->webapp;
my $run = Sunaba::Runner->to_app;

my $wrapped = sub {
    my $env = shift;

    my $host = $env->{HTTP_HOST};
       $host =~ s/:\d+$//;

    if ($host eq '127.0.0.1') {
        return $app->($env);
    } elsif ($host eq 'localhost' && $env->{PATH_INFO} =~ s!/([\w\-]+)!!) {
        $env->{'sunaba.app_id'} = $1;
        $env->{SCRIPT_NAME} = "/$1";
        return $run->($env);
    } else {
        return [ 404, ["Content-Type", "text/plain"], ["Not Found"] ];
    }
};

builder {
    enable "Static", path => sub { s!^/packed/!fatpacked/! };
    $wrapped;
};




