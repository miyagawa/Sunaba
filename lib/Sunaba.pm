package Sunaba;
use strict;
use 5.008_001;
our $VERSION = '0.01';

use Tatsumaki::Application;
use Sunaba::DB;

sub h($) {
    my $class = shift;
    $class = "Sunaba::Handler" . $class;
    eval "require $class" or die $@;
    $class;
}

sub webapp {
    my $class = shift;

    my $app = Tatsumaki::Application->new([
        '/create'           => h '::Create',
        '/app/([\w\-]+)'    => h '::Edit',
        qr'^/$'             => h '::Root',
    ]);

    $app->add_service(db => Sunaba::DB->new);
    $app->psgi_app;
}

1;
