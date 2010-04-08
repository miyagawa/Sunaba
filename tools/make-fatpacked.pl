#!/usr/bin/env perl
use strict;

my $module = shift or die $!;
(my $pkg = $module) =~ s/::/-/g;

mkdir "tmp", 0777;
chdir "tmp";
mkdir "lib", 0777;

open my $script, ">fp.pl";
print $script "use $module ();";
close $script;

system "fatpack trace fp.pl";
system "fatpack packlists-for `cat fatpacker.trace` > packlists";
system "fatpack tree `cat packlists`";
system "fatpack file > ../fatpacked/$pkg";

chdir "..";
system "rm -fr tmp";
