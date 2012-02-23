#!/usr/bin/perl
use XML::Simple;
use Getopt::Std;
use Data::Dumper;
use strict;

our ( $opt_m, $opt_v, $opt_b );
our $VERSION = '0.01';

getopts("m:v:b:");
HELP_MESSAGE('The -m option is required.') unless $opt_m;

$opt_m =~ s/\.xml$//;
HELP_MESSAGE('File '. $opt_m . '.xml not found.') unless -f $opt_m . '.xml';

my $file = $opt_m . '.xml';

my $bot = $opt_b ? $opt_b : 'fajita';
my $addr = $bot . ': ';

my $xs = XML::Simple->new();
my $xml = $xs->XMLin( $file );

print $addr . "forget $opt_m\n";
print $addr . "$opt_m is " . 'http://httpd.apache.org/docs/' . ( $opt_v ? $opt_v : 'current' ) . '/mod/' . $opt_m .  '.html' . "\n\n";

my @directives;
foreach my $directive ( sort( keys %{ $xml->{directivesynopsis} } ) ) {

    my $d = $xml->{directivesynopsis}->{$directive};

    my $desc = $d->{description}; $desc =~ s/[\r\n]/ /gs;
    my $name = $directive . ( $opt_v ? " $opt_v" : '' );

    print $addr . "forget $name\n";
    print $addr . "$name is ";
    print 'http://httpd.apache.org/docs/' . ( $opt_v ? $opt_v : 'current' ) . '/mod/' . $opt_m .  '.html#' . lc( $directive ) .  " - ";
    print $desc . "\n";

    print $addr . "forget $name default\n";
    if ( $d->{default} ) {
        print $addr . "$name default is " . $d->{default} . "\n";
    } else {
        print $addr . "$name default is <reply>$name has not default value";
    }

    print $addr . "forget $name override\n";
    if ( $d->{override} ) {
        print $addr . "$name override is <reply>$name may be used in an .htaccess file if AllowOverride is set to ".$d->{override}."\n";
    } else {
        print $addr . "$name override is <reply>$name may not be used in a .htaccess file\n";
    }

    print $addr . "forget $name context\n";
    print $addr . "$name context is <reply>$name may be used in the following contexts: ";
    print ( join ', ', @{ $d->{contextlist}->{context} } ) . "\n";
    print "\n\n";

}
print "\n";

sub HELP_MESSAGE {
    print shift;
    print STDERR qq~

Usage: 

cd manual/mod
../../review_translations.pl -m mod_rewrite

Outputs IRC factoids for the directives in this module, which can then
be fed to the IRC bot.

-m mod_foo - Run for mod_foo.

-v version - Generate URLs for this version. Defaults to "current"

~;

    exit();
}


