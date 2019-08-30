#!/usr/bin/perl

my $file = shift;

my $out;

open(IN, "$file");
while(<IN>) {
	last;
}

while(<IN>) {
	chomp();
	my($prot,$taxid,$sk,$k,$p,$c,$o,$f,$g,$s) = split(/\t/);

	#print "sk is $sk\n";

	$sk = "unknown" if $sk eq "";
        $k = "unknown" if $k eq "";
        $p = "unknown" if $p eq "";
        $c = "unknown" if $c eq "";
        $o = "unknown" if $o eq "";
        $f = "unknown" if $f eq "";
        $g = "unknown" if $g eq "";
        $s = "unknown" if $s eq "";

	#print "so sk is now $sk\n";

	$out->{sk}->{$sk}++;
	$out->{k}->{$k}++;
	$out->{p}->{$p}++;
	$out->{c}->{$c}++;
	$out->{o}->{$o}++;
	$out->{f}->{$f}++;
	$out->{g}->{$g}++;
	$out->{s}->{$s}++;
	
}
close IN;

print $file;

#print join(";", keys %{$out->{sk}}), "\n";

#foreach $tax ("sk") {
foreach $tax ("sk","k","p","c","o","f","g","s") {


	my $hr = $out->{$tax};


	my @sorted = sort {$hr->{$b} <=> $hr->{$a}} keys %{$hr};

	my $biggest = shift @sorted;
	if ($biggest eq "unknown") {
		$biggest = shift @sorted;
	}

	my $sum = 0;
	foreach $s (@sorted) {
		next if ($s eq "unknown");
		#print "$s:", $hr->{$s}, "\n";
		$sum += $hr->{$s};
	}

	print "\t$sum";

	
}

print "\n";
