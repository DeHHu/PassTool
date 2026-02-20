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

our @PREFIX                     = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl' );
our @libdir                     = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl' );
our @BINDIR                     = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl/apps' );
our @BINDIR_REL_PREFIX          = ( 'apps' );
our @LIBDIR                     = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl' );
our @LIBDIR_REL_PREFIX          = ( '' );
our @INCLUDEDIR                 = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl/include', '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl/include' );
our @INCLUDEDIR_REL_PREFIX      = ( 'include', './include' );
our @APPLINKDIR                 = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl/ms' );
our @APPLINKDIR_REL_PREFIX      = ( 'ms' );
our @MODULESDIR                 = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl/providers' );
our @MODULESDIR_REL_LIBDIR      = ( 'providers' );
our @PKGCONFIGDIR               = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl' );
our @PKGCONFIGDIR_REL_LIBDIR    = ( '' );
our @CMAKECONFIGDIR             = ( '/Volumes/Store/Work/Projects/PassTool/Vendor/openssl' );
our @CMAKECONFIGDIR_REL_LIBDIR  = ( '' );
our $VERSION                    = '4.0.0-dev';
our @LDLIBS                     =
    # Unix and Windows use space separation, VMS uses comma separation
    $^O eq 'VMS'
    ? split(/ *, */, ' ')
    : split(/ +/, ' ');

1;
