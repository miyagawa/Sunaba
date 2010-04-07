package Sunaba::Handler::Edit;
use strict;
use parent qw(Tatsumaki::Handler);
__PACKAGE__->asynchronous(1);

use Sunaba::View;

sub get {
    my $self = shift;
    my($id)  = @_;

    my $db = $self->application->service('db');

    my $cb = sub {
        my($dbh, $rows, $rv) = @_;
        $self->write( Sunaba::View->render('app', { handler => $self, app => $db->inflate($rows->[0]) }) );
        $self->finish;
    };

    $db->select("app", '*', { id => $id }, $self->async_cb($cb));
}

sub post {
    my($self, $id) = @_;

    if ($self->request->param('clone')) {
        my $create_handler = Sunaba::Handler::Create->can('post');
        return $self->$create_handler();
    }

    my $meta = {
        created_on => time,
        created_by => $self->request->address,
        user_agent => $self->request->user_agent,
    };

    my $data = {
        code => $self->request->parameters->{code},
        meta => JSON::encode_json($meta),
    };

    my $db = $self->application->service('db');
    $db->update(
        "app", $data, { id => $id },
        $self->async_cb(sub { $self->response->redirect("/app/$id"); $self->finish }),
    );
}

1;
