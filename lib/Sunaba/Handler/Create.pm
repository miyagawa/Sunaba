package Sunaba::Handler::Create;
use strict;
use parent qw(Tatsumaki::Handler);
__PACKAGE__->asynchronous(1);

use Digest::SHA1 qw(sha1_hex);
use JSON;

sub gen_random {
    sha1_hex(rand(1000) . $$ . {} . time);
}

sub post {
    my $self = shift;

    my $meta = {
        created_on => time,
        created_by => $self->request->address,
        user_agent => $self->request->user_agent,
    };

    my $data = {
        id   => gen_random(),
        code => $self->request->parameters->{code},
        meta => JSON::encode_json($meta),
    };

    my $db = $self->application->service('db');
    $db->insert(
        "app", $data,
        $self->async_cb(sub { $self->response->redirect("/app/$data->{id}"); $self->finish }),
    );
}

1;
