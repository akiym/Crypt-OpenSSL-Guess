
# NAME

Crypt::OpenSSL::Guess - It's new $module

# SYNOPSIS

    use Crypt::OpenSSL::Guess;

# DESCRIPTION

Crypt::OpenSSL::Guess is ...

# FUNCTIONS

- openssl\_inc\_paths()

        openssl_inc_paths(); # on MacOS: "-I/usr/local/opt/openssl/include"

- find\_openssl\_prefix(\[$dir\])

        find_openssl_prefix(); # on MacOS: "/usr/local/opt/openssl"

- find\_openssl\_exec($prefix)

        find_openssl_exec(); # on MacOS: "/usr/local/opt/openssl/bin/openssl"

- ($major, $minor, $letter) = openssl\_version()

        openssl_version(); # ("1.0", "2", "n")

# SEE ALSO

[Net::SSLeay](https://metacpan.org/pod/Net::SSLeay)

# LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Takumi Akiyama <t.akiym@gmail.com>
