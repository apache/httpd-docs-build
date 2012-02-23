#!/usr/bin/perl
use XML::Simple;
use Getopt::Std;
use Data::Dumper;
use strict;

our ( $opt_m, $opt_v );
our $VERSION = '0.01';

getopts("m:v:");
HELP_MESSAGE('The -m option is required.') unless $opt_m;

$opt_m =~ s/\.xml$//;
HELP_MESSAGE('File '. $opt_m . '.xml not found.') unless -f $opt_m . '.xml';

my $file = $opt_m . '.xml';
my $v = $opt_v ? $opt_v : 'current';

my $xs = XML::Simple->new();
my $xml = $xs->XMLin( $file );

my @directives;
foreach my $directive ( sort( keys %{ $xml->{directivesynopsis} } ) ) {
    print $directive . "\n";
    print 'http://httpd.apache.org/docs/' . $v . '/mod/' . $opt_m .  '.html#' . lc( $directive ) .  "\n";

    my $d = $xml->{directivesynopsis}->{$directive};

    my $desc = $d->{description}; $desc =~ s/[\r\n]/ /gs;
    print $desc . "\n";
    print 'Default: ' . $d->{default} . "\n";
    print 'Override: ' . $d->{override} . "\n";
    print 'Context: ' . ( join ', ', @{ $d->{contextlist}->{context} } ) . "\n";
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


