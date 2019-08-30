#!/usr/bin/perl

my %done;

my $file = shift;

open(IN, $file);
while(<IN>) {
	chomp();
	my @res = split(/\t/);

	next if exists $done{$res[0]};

	print $res[0];

	my $taxid = undef;
	if (m/OX=(\d+)/) {
		$taxid=$1;
	}

	print "\t$taxid\n";

	$done{$res[0]}++;
}

close IN;
