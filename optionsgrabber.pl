use strict;
use warnings;
use utf8;

use pkgng qw(:all);

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


my $optionstemplate = <<'TEST';
# Options for %name%-%version%
_OPTIONS_READ=%name%-%version%
_FILE_COMPLETE_OPTIONS_LIST=%alloptions%
TEST
my $setoptiontemplate="OPTIONS_FILE_SET+=";
my $unsetoptiontemplate="OPTIONS_FILE_UNSET+=";


sub ports_options_db ($) {
    # output package options in the format that is used in /var/db/ports/$origin/options
    my $package = shift;
    my $package_id = get_package_id_by_name($package);
    my $package_version = get_package_version_by_id($package_id);
    my $package_origin = get_package_origin_by_id($package_id);
    my %options = get_package_options_by_id($package_id);
    $_ = $optionstemplate;
    s/%name%/$package/mg;
    s/%version%/$package_version/mg;
    my $alloptions = "";
    $alloptions .= $_." " for (sort (keys %options));
    s/%alloptions%/$alloptions/;
    my $output = $_;
    for (sort keys %options) {
        if ($options{$_}) {
            $output .= $setoptiontemplate.$_."\n";
        } else {
            $output .= $unsetoptiontemplate.$_."\n" ;
        }
    }
    print $output;
}



# main
my $pkg = shift;
init_local_handle();
ports_options_db($pkg);
kill_all_handles();
