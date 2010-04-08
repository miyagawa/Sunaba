package Sunaba::Model::App;
use Any::Moose;

has id    => (is => 'rw', isa => 'Str');
has code  => (is => 'rw', isa => 'Str');
has meta  => (is => 'rw', isa => 'Str');
has _meta => (is => 'rw', isa => 'HashRef', lazy_build => 1);

use Encode;
use Data::Dump;
use JSON;

sub _build__meta {
    my $self = shift;
    JSON::decode_json($self->meta);
}

sub new_from_rv {
    my($class, @cols) = @_;

    my $self = $class->new;
    $self->id($cols[0]);
    $self->code($cols[1]);
    $self->meta($cols[2]);

    $self;
}

sub url {
    my $self = shift;

    if ($ENV{SUNABA_DEV}) {
        return "http://localhost:5000/" . $self->id;
    } else {
        return "http://" . $self->id . ".sunaba-app.plackperl.org/";
    }
}

sub can_edit {
    my($self, $request) = @_;
    $self->_meta->{user_agent} eq $request->user_agent and
    $self->_meta->{created_by} eq $request->address;
}

sub compile_runtime {
    my($self, $env) = @_;

    # make psgi.input a raw string - revert it to a handle on the server side
    if ($env->{CONTENT_LENGTH}) {
        $env->{'psgi.input'} = do {
            $env->{'psgi.input'}->read(my($content), $env->{CONTENT_LENGTH}, 0);
            $content;
        };
    } else {
        $env->{'psgi.input'} = '';
    }

    my $code = "#!/usr/bin/perl\n";
    $code .= "my \$_app = do { " . $self->unpack_use($self->code) . "};\n";
    $code .= "my \$_env = " . Data::Dump::pp($env) . ";\n";
    $code .= "\$_env->{'psgi.input'}  = do { open my \$io, '<', \$_env->{'psgi.input'}; \$io };\n";
    $code .= "\$_env->{'psgi.errors'} = \\*STDOUT;\n";
    $code .= "use Storable;\nuse MIME::Base64;\nprint STDOUT encode_base64(Storable::nfreeze(\$_app->(\$_env)));";

    return $code;
}

sub unpack_use {
    my($self, $code) = @_;

    my @modules = $code =~ m/^use (\S+).*?;\s*#\s*sunaba/mg;

    if (@modules) {
        my $loader = "BEGIN {\nuse LWP::Simple ();\n";
        for my $module (@modules) {
            (my $dist = $module) =~ s/::/-/g;
            $loader .= qq{eval(LWP::Simple::get("http://sunaba.plackperl.org/packed/$dist"));};
        }
        $loader .= "}\n";
        $code = $loader . $code;
    }

    $code;
}

sub ucode {
    my $self = shift;
    Encode::decode_utf8($self->code);
}

1;
