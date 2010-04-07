package Sunaba::Handler::Create;
use strict;
use parent qw(Tatsumaki::Handler);
__PACKAGE__->asynchronous(1);

use Data::UUID;
use MIME::Base64::URLSafe;
use JSON;

my $uid = Data::UUID->new;

sub gen_random {
    lc(urlsafe_b64encode($uid->create));
}

sub post {
    my $self = shift;

    my $meta = {
        created_on => time,
        created_by => $self->request->address,
        user_agent => $self->request->user_agent,
    };

    # TODO specify Tatsumaki::Request to get UTF-8 bytes of 'code'

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
