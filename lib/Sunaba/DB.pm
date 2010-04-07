package Sunaba::DB;
use strict;
use Any::Moose;
extends 'Tatsumaki::Service';

use AnyEvent::DBI::Abstract;
use Sunaba::Model::App;

has dbi => (is => 'rw', isa => 'AnyEvent::DBI::Abstract', lazy_build => 1);
has dsn => (is => 'rw', isa => 'ArrayRef', default => sub { [ 'dbi:SQLite:dbname=sunaba.db', 'root', undef ] });

sub _build_dbi {
    my $self = shift;
    AnyEvent::DBI::Abstract->new(@{$self->dsn});
}

sub start {
    my $self = shift;
    $self->dbi;
}

sub inflate {
    my $self = shift;
    my $row  = shift;
    Sunaba::Model::App->new_from_rv(@$row);
}

sub select { shift->dbi->select(@_) }
sub insert { shift->dbi->insert(@_) }
sub update { shift->dbi->update(@_) }
sub delete { shift->dbi->delete(@_) }

1;
