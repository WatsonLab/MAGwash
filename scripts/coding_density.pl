#!/usr/bin/perl

my $fa = shift;
my $gff = shift;

my %lengths;

my %contigs;

my $cc = undef;
open(IN, "$fa");
while(<IN>) {
	chomp();
	if (m/^>(\S+)/) {
		$cc = $1;
		next;
	}

	$contigs{$cc}++;

	$lengths{$cc} += length $_;
}
close IN;

my %coding;

open(IN, "$gff");
while(<IN>) {
	chomp();
	next if (m/^#/);

	my @d = split(/\t/);

	next unless $d[2] eq "CDS";

	$coding{$d[0]} += $d[4]-$d[3]+1;
}
close IN;

foreach $c (keys %contigs) {
	print $c;
	print "\t", $lengths{$c};
	print "\t", $coding{$c};
	print "\t", sprintf("%0.2f", $coding{$c}/$lengths{$c});
	print "\n"; 
}
