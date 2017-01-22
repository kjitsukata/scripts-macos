#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Term::ANSIColor;

sub get_package_version {
    my $package_name = shift;
    my ($package_current_version, $package_local_version);
    my @package_info = `brew cask info $package_name`;
    foreach my $line (@package_info) {
        if ($line =~ /^$package_name: /) {
            $package_current_version = $';
            chomp $package_current_version;
        } elsif ($line =~ /\/usr\/local\/Caskroom\/${package_name}\/(.+?) /) {
            $package_local_version = $1;
            chomp $package_local_version;
        } else {
            next;
        }
    }
    return ($package_current_version, $package_local_version);
}

sub print_color_line {
    my $str = shift;
    print color("bold blue"), "==> ", color("reset") . color("bold"), "$str\n", color("reset");
}

print_color_line("brew cleanup");
system ("brew cleanup");

print_color_line("brew cask cleanup");
system ("brew cask cleanup");

print_color_line("brew update");
system ("brew update");

print_color_line("brew upgrade");
system ("brew upgrade");

print_color_line("brew cask upgrade");
my $update_cask_package_cnt = 0;
my @cask_packages = `brew cask list`;

foreach my $cask_package (@cask_packages) {
    chomp $cask_package;
    my ($cask_current_version, $cask_local_version) = get_package_version($cask_package);
    if ($cask_current_version eq $cask_local_version) {
        next;
    } else {
        print_color_line("brew cask upgrade ${cask_package}");
        system ("brew cask reinstall ${cask_package}");
        $update_cask_package_cnt++
    }
}

if ($update_cask_package_cnt == 0) {
    print "Already up-to-date.\n";
}
