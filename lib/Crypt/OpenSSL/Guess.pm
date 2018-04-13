package Crypt::OpenSSL::Guess;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use File::Spec;
use Config;
use Symbol qw(gensym);

use Exporter 'import';

our @EXPORT = qw(openssl_inc_paths find_openssl_prefix find_openssl_exec openssl_version);

sub openssl_inc_paths {
    my $prefix = find_openssl_prefix();
    my $exec   = find_openssl_exec($prefix);

    return '' unless -x $exec;

    my @inc_paths;
    for ("$prefix/include", "$prefix/inc32", '/usr/kerberos/include') {
        push @inc_paths, $_ if -f "$_/openssl/ssl.h";
    }

    return join ' ', map { "-I$_" } @inc_paths;
}

my $other_try = 0;
my @nopath;
sub check_no_path {            # On OS/2 it would be typically on default paths
    my $p;
    if (not($other_try++) and $] >= 5.008001) {
       use ExtUtils::MM;
       my $mm = MM->new();
       my ($list) = $mm->ext("-lssl");
       return unless $list =~ /-lssl\b/;
        for $p (split /\Q$Config{path_sep}/, $ENV{PATH}) {
           @nopath = ("$p/openssl$Config{_exe}",       # exe name
                      '.')             # dummy lib path
               if -x "$p/openssl$Config{_exe}"
       }
    }
    @nopath;
}

sub find_openssl_prefix {
    my ($dir) = @_;

    if (defined $ENV{OPENSSL_PREFIX}) {
        return $ENV{OPENSSL_PREFIX};
    }

    my @guesses = (
        '/home/linuxbrew/.linuxbrew/opt/openssl/bin/openssl' => '/home/linuxbrew/.linuxbrew/opt/openssl', # LinuxBrew openssl
        '/usr/local/opt/openssl/bin/openssl' => '/usr/local/opt/openssl', # OSX homebrew openssl
        '/usr/local/bin/openssl'         => '/usr/local', # OSX homebrew openssl
        '/opt/local/bin/openssl'         => '/opt/local', # Macports openssl
        '/usr/bin/openssl'               => '/usr',
        '/usr/sbin/openssl'              => '/usr',
        '/opt/ssl/bin/openssl'           => '/opt/ssl',
        '/opt/ssl/sbin/openssl'          => '/opt/ssl',
        '/usr/local/ssl/bin/openssl'     => '/usr/local/ssl',
        '/usr/local/openssl/bin/openssl' => '/usr/local/openssl',
        '/apps/openssl/std/bin/openssl'  => '/apps/openssl/std',
        '/usr/sfw/bin/openssl'           => '/usr/sfw', # Open Solaris
        'C:\OpenSSL\bin\openssl.exe'     => 'C:\OpenSSL',
        'C:\OpenSSL-Win32\bin\openssl.exe'        => 'C:\OpenSSL-Win32',
        $Config{prefix} . '\bin\openssl.exe'      => $Config{prefix},           # strawberry perl
        $Config{prefix} . '\..\c\bin\openssl.exe' => $Config{prefix} . '\..\c', # strawberry perl
        '/sslexe/openssl.exe'            => '/sslroot',  # VMS, openssl.org
        '/ssl$exe/openssl.exe'           => '/ssl$root', # VMS, HP install
    );

    while (my $k = shift @guesses
           and my $v = shift @guesses) {
        if ( -x $k ) {
            return $v;
        }
    }
    (undef, $dir) = check_no_path()
       and return $dir;

    return;
}

sub find_openssl_exec {
    my ($prefix) = @_;

    my $exe_path;
    for my $subdir (qw( bin sbin out32dll ia64_exe alpha_exe )) {
        my $path = File::Spec->catfile($prefix, $subdir, "openssl$Config{_exe}");
        if ( -x $path ) {
            return $path;
        }
    }
    ($prefix) = check_no_path()
       and return $prefix;
    return;
}

sub openssl_version {
    my ($major, $minor, $letter);

    my $prefix = find_openssl_prefix();
    my $exec   = find_openssl_exec($prefix);

    return unless -x $exec;

    {
        my $pipe = gensym();
        open($pipe, qq{"$exec" version |})
            or die "Could not execute $exec";
        my $output = <$pipe>;
        chomp $output;
        close $pipe;

        if ( ($major, $minor, $letter) = $output =~ /^OpenSSL\s+(\d+\.\d+)\.(\d+)([a-z]?)/ ) {
        } elsif ( ($major, $minor) = $output =~ /^LibreSSL\s+(\d+\.\d+)\.(\d+)/ ) {
        } else {
            die <<EOM
*** OpenSSL version test failed
    (`$output' has been returned)
    Either you have bogus OpenSSL or a new version has changed the version
    number format. Please inform the authors!
EOM
        }
    }

    return ($major, $minor, $letter);
}

1;
__END__

=encoding utf-8

=head1 NAME

Crypt::OpenSSL::Guess - It's new $module

=head1 SYNOPSIS

    use Crypt::OpenSSL::Guess;

=head1 DESCRIPTION

Crypt::OpenSSL::Guess is ...

=head1 FUNCTIONS

=over 4

=item openssl_inc_paths()

    openssl_inc_paths(); # on MacOS: "-I/usr/local/opt/openssl/include"

=item find_openssl_prefix([$dir])

    find_openssl_prefix(); # on MacOS: "/usr/local/opt/openssl"

=item find_openssl_exec($prefix)

    find_openssl_exec(); # on MacOS: "/usr/local/opt/openssl/bin/openssl"

=item ($major, $minor, $letter) = openssl_version()

    openssl_version(); # ("1.0", "2", "n")

=back

=head1 SEE ALSO

L<Net::SSLeay>

=head1 LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takumi Akiyama E<lt>t.akiym@gmail.comE<gt>

=cut

