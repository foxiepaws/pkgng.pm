package pkgng;
use strict;
use warnings;
use utf8;

use DBI;
use Data::Dumper;
require Exporter; 
our @ISA = qw(Exporter);
our $VERSION = 0.0.1;
# our @EXPORT = qw();
our @EXPORT_OK = qw( get_package_origin_by_name get_package_version_by_name get_package_id_by_name get_package_deps_by_name get_package_options_by_name
get_package_origin_by_id get_package_version_by_id get_package_name_by_id get_package_deps_by_id get_package_options_by_id 
init_local_handle init_remote_handle disconnect_handle kill_all_handles 
);
our %EXPORT_TAGS = (id => [qw( get_package_origin_by_id get_package_version_by_id get_package_name_by_id get_package_deps_by_id get_package_options_by_id )],
                    name => [qw( get_package_origin_by_name get_package_version_by_name get_package_id_by_name get_package_deps_by_name get_package_options_by_name )], 
                    handles => [qw( init_local_handle init_remote_handle disconnect_handle kill_all_handles )], 
                    all => [@EXPORT_OK]
                   );

# default config.
our %config = (
    pkgdb => "/var/db/pkg/",
    portsdb => "/var/db/ports/"
);

# handles to databases (e.g. local and remote repo)
our %handles = ();


### local database
## get
# package info by name
sub get_package_origin_by_name ($) {
    my $package = shift;
    my $sth = $handles{'local'}->prepare("SELECT origin from packages where name = ?");
    my $rv = $sth->execute($package);
    return $sth->fetchrow() if $rv ;
}
sub get_package_id_by_name ($) {
    my $package = shift;
    my $sth = $handles{'local'}->prepare("SELECT rowid from packages where name = ?");
    my $rv = $sth->execute($package);
    return $sth->fetchrow() if $rv ;
}
sub get_package_version_by_name ($) {
    my $package = shift;
    my $sth = $handles{'local'}->prepare("SELECT version from packages where name = ?");
    my $rv = $sth->execute($package);
    return $sth->fetchrow() if $rv ;
}
sub get_package_deps_by_name ($) {
    my $package = shift;
    my $package_id = get_package_id_by_name($package);
    return get_package_deps_by_id($package_id);
}
sub get_package_options_by_name ($) {
    my $package = shift;
    my $package_id = get_package_id_by_name($package);
    return get_package_options_by_id($package_id);
}

# package info by id
sub get_package_origin_by_id ($) {
    my $package_id = shift;
    my $sth = $handles{'local'}->prepare("SELECT origin from packages where rowid = ?");
    my $rv = $sth->execute($package_id);
    return $sth->fetchrow() if $rv ;
}
sub get_package_name_by_id ($) {
    my $package_id = shift;
    my $sth = $handles{'local'}->prepare("SELECT name from packages where rowid = ?");
    my $rv = $sth->execute($package_id);
    return $sth->fetchrow() if $rv ;
}
sub get_package_version_by_id ($) {
    my $package_id = shift;
    my $sth = $handles{'local'}->prepare("SELECT version from packages where rowid = ?");
    my $rv = $sth->execute($package_id);
    return $sth->fetchrow() if $rv ;
}
sub get_package_deps_by_id ($) {
    my $package_id = shift;
    my @deps = ();
    my $sth = $handles{'local'}->prepare("SELECT * from deps where package_id = ?");
    my $rv = $sth->execute($package_id);
    if ($rv) {
        while (my $_ = $sth->fetchrow_hashref) {
            my %row = %{$_};
            push @deps, $row{'name'};
        }
        return @deps;
    }
    return undef;
}
sub get_package_options_by_id ($) {
    my $package_id = shift;
    my %options = ();

    my $sth = $handles{'local'}->prepare("SELECT option,value from options where package_id = ?");
    my $rv = $sth->execute($package_id);
    if ($rv) {
        while (my $_ = $sth->fetchrow_hashref) {
            my %row = %{$_};
            #print $row{option},": ", $row{value},"\n";
            $options{$row{option}} = $row{value} =~ /yes|on/ ? 1 : 0;
        }
        return %options;
    }
    return undef;
}

## set/add
# WARNING: you /MUST/ KNOW WHAT YOU ARE DOING
# TODO: implement these. 
###

### remote (repo) databases
# TODO: implement these.
###

# handle manipulation
sub init_local_handle () {
    # connect to the local database.
    my $dbh = DBI->connect("dbi:SQLite:dbname=${config{'pkgdb'}}/local.sqlite") ||
        die "cannot connect: $DBI::errstr";
    $handles{'local'} = $dbh;

}
sub init_remote_handle ($) {
    # connect to a remote repository database
    my $repo = shift;
    my $dbh = DBI->connect("dbi:SQLite:dbname=${config{'pkgdb'}}/${repo}.sqlite") ||
        die "cannot connect: $DBI::errstr";
    $handles{$repo} = $dbh;
}
sub disconnect_handle ($) {
    my $handle = shift;
    $handles{$handle}->disconnect;
}
sub kill_all_handles () {
    # disconnect all handles.
    $_->disconnect for (values %handles);
}


1
