#!/usr/bin/perl

my $limit = 0.4;

my $ncon=0;
my $lcon=0;
my $tot=0;
my $cnt=0;

my $in = shift;
open(IN, $in);
while(<IN>) {

	chomp();
	my($con,$len,$cod,$perc) = split(/\t/);

	if ($perc < $limit) {
		$lcon+=$len;
		$ncon++;
	}

	$cnt++;
	$tot+=$len;

}

close IN;

print "$in\t$tot\t$lcon\t$cnt\t$ncon\n";
