package Sunaba::Handler::Root;
use strict;
use parent qw(Tatsumaki::Handler);

use Sunaba::View;

sub get {
    my $self = shift;
    $self->write( Sunaba::View->render('index', { handler => $self }) );
}

1;
