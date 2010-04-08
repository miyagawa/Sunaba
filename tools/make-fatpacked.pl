#!/usr/bin/env perl
use strict;

my $module = shift or die $!;
(my $pkg = $module) =~ s/::/-/g;

open my $script, ">fp.pl";
print $script "use $module ();";
close $script;

system "fatpack trace fp.pl";
system "fatpack packlists-for `cat fatpacker.trace` > packlists";
system "fatpack tree `cat packlists`";
system "fatpack file > fatpacked/$pkg";

unlink $_ for qw( fp.pl packlists fatpacker.trace );
