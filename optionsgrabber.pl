use strict;
use warnings;
use utf8;

use pkgng qw(:id :name :handles);

# output stuff
sub almost_pkginfo($){
    my $pkg = shift;
    print "Package Version: ",get_package_version_by_name($pkg),"\n";
    print "Package Origin : ",get_package_origin_by_name($pkg),"\n";
    print "Package ID     : ",get_package_id_by_name($pkg),"\n";
    print "Package Deps   :\n";
    print "\t",$_,"\n" for get_package_deps_by_name($pkg);
    print "Package Options:\n";
    (sub (%){
            my %opts = @_;
            for (keys %opts) {
                print "\t",$_,": ",($opts{$_} ? "on" : "off"),"\n"
            }
        }
    )->(get_package_options_by_name($pkg));
}
#sub ports_options_db ($) {
#    # output package options in the format that is used in /var/db/ports/$origin/options
#    my $package = shift;
#    my $package_id = get_package_id_by_name($package);
#    my $package_origin = get_pkg_origin_by_id($package_id);
#}

# main
my $pkg = shift;
init_local_handle();
almost_pkginfo($pkg);
kill_all_handles();
