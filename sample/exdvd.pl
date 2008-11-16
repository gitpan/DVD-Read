#!/bin/env perl

use strict;
use warnings;
use DVD::Read;

my ($location, $titleno, $chapter, $file) = @ARGV;

my $dvd = DVD::Read->new($location) or do {
    warn "Cant read $location\n";
    next;
};

print ($dvd->volid || '');
printf(" %d titles\n",
    $dvd->titles_count);

my $title = $dvd->get_title($titleno);

$title->extract_chapter($chapter, $file);
