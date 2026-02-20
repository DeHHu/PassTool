package OpenSSL::safe::installdata;

use strict;
use warnings;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(
    @PREFIX
    @libdir
    @BINDIR @BINDIR_REL_PREFIX
    @LIBDIR @LIBDIR_REL_PREFIX
    @INCLUDEDIR @INCLUDEDIR_REL_PREFIX
    @APPLINKDIR @APPLINKDIR_REL_PREFIX
    @MODULESDIR @MODULESDIR_REL_LIBDIR
    @PKGCONFIGDIR @PKGCONFIGDIR_REL_LIBDIR
    @CMAKECONFIGDIR @CMAKECONFIGDIR_REL_LIBDIR
    $VERSION @LDLIBS
);

our @PREFIX                     = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl' );
our @libdir                     = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/lib' );
our @BINDIR                     = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/bin' );
our @BINDIR_REL_PREFIX          = ( 'bin' );
our @LIBDIR                     = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/lib' );
our @LIBDIR_REL_PREFIX          = ( 'lib' );
our @INCLUDEDIR                 = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/include' );
our @INCLUDEDIR_REL_PREFIX      = ( 'include' );
our @APPLINKDIR                 = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/include/openssl' );
our @APPLINKDIR_REL_PREFIX      = ( 'include/openssl' );
our @MODULESDIR                 = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/lib/ossl-modules' );
our @MODULESDIR_REL_LIBDIR      = ( 'ossl-modules' );
our @PKGCONFIGDIR               = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/lib/pkgconfig' );
our @PKGCONFIGDIR_REL_LIBDIR    = ( 'pkgconfig' );
our @CMAKECONFIGDIR             = ( '/Volumes/Store/Work/Projects/PassTool/.vendor/openssl/lib/cmake/OpenSSL' );
our @CMAKECONFIGDIR_REL_LIBDIR  = ( 'cmake/OpenSSL' );
our $VERSION                    = '4.0.0-dev';
our @LDLIBS                     =
    # Unix and Windows use space separation, VMS uses comma separation
    $^O eq 'VMS'
    ? split(/ *, */, ' ')
    : split(/ +/, ' ');

1;
