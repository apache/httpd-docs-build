#!/usr/bin/perl
#
# update_mime_types.pl: Read an existing Apache mime.types file and
# merge its entries with any new types discovered within an
# IANA media-types.xml file (see below for obtaining it).
#
# All existing mime.types entries are preserved as is (aside from sorting).
# Any new registered types are merged as a commented-out entry without
# an assigned extension, and then the entire file is printed to stdout.
#
# Typical use would be something like:
# 
#  wget -N https://www.iana.org/assignments/media-types/media-types.xml
#  ./update_mime_types.pl mime.types > new.types
#  diff -u mime.types new.types               ; check the differences
#  rm mime.types && mv new.types mime.types   ; only if diffs are good
#
# Note that we assume most files are in the current working directory
# and efficiency is not an issue.  The first argument, if any, is the
# path to the existing mime.types file (or its directory).
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

my $mity = 'mime.types';
my $medy = 'media-types.xml';

# if an argument is given, look there for mime.types
# otherwise, look in current working directory for all files

if ($#ARGV >= 0) {
    if (-d $ARGV[0]) {
        $mity = $ARGV[0] . '/' . $mity;
    }
    else {
        $mity = $ARGV[0];
    }
} 

die "no $mity here\n" unless (-e $mity);
die "no $medy here\n" unless (-e $medy);

my $in_head = 1;
my @header = ();
my %mtype = ();

# Read through the Apache httpd mime.types file to create tables
# keyed on the minor type names.  We save the entire input line as
# the hash value so that existing configs won't change when output.
# We assume the type names are already lowercased tokens.
#
die "cannot open $mity: $!" unless open (MIME, "<", $mity);

while (<MIME>) {
    if ($in_head) {
        push @header, $_;
        if (/^# =========/) {
            $in_head = 0;
        }
        next;
    }
    if (/^(# )?([a-z_\+\-\.]+\/\S+)/) {
        $mtype{$2} = $_;
    }
    else {
        warn "Skipping: ", $_;
    }
}
close MIME;

# Read through the IANA media types registry, in XML form, and extract
# whatever looks to be a registered type based on the element structure.
# Yes, this is horribly fragile, but the format isn't expected to change.
#
die "cannot open $medy: $!" unless open (IANA, "<", $medy);

my $major    = 'examples';
my $thistype = '';

while (<IANA>) {
    last if (/^\s*<people>/);
    next if (/(OBSOLETE|DEPRECATE)/);

    if (/^\s*<registry id="([a-z_\+\-\.]+)"/) {
        $major = $1;
        next;
    }
    next if ($major eq 'examples');

    if (/^\s*<name>([^<]+)<\/name>/) {
        $thistype = lc "$major/$1";
        if (!defined($mtype{$thistype})) {
            $mtype{$thistype} = "# $thistype\n";
        }
    }
}
close IANA;

# Finally, output a replacement for Apache httpd's mime.types file
#
print @header;

foreach $key (sort(keys %mtype)) {
    print $mtype{$key};
}

exit 0;