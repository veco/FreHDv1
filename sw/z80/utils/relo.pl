#!/usr/bin/perl


#
# Look for lines starting with rx\d+. These lines are replaced by rx.., where .. is
# renumbered from 0.
#
# Then look for line starting with "reltab\s", and recreated the reltab table.
#

my $file = @ARGV[0];
my $file2 = $file . ".rel";
my $n = 0;
my $where = 0;

open(F, "<$file") or die "Can't open $file : $!\n";
open(G, ">$file2") or die "Can't create $file2 : $!\n";
while (<F>) {
    if ($where == 0) {
	if (/^rx\d+\s/) {
	    $r = sprintf("rx%02d", $n);
	    s/^(rx\d+)/$r/;
	    $n++;
	}
	if (/^reltab\s/) {
	    $where = 1;
	} else {
	    print G $_;
	}
    } elsif ($where == 1) {
	$i = 0;
	while ($i < $n) {
	    if ($i == 0) {
		$str = "reltab\tdw\t";
	    } else {
		$str = "\tdw\t";
	    }
	    $j = 0;
	    while ($j < 8 && $i < $n) {
		$s = sprintf("rx%02d", $i);
		if ($j == 0) {
		    $str .= $s;
		} else {
		    $str .= ",";
		    $str .= $s;
		}
		$i++;
		$j++;
	    }
	    print G $str,"\n";
	}
	$where = 2;
    } elsif ($where == 2) {
	if (/\s*dw\s*0/) {
	    print G $_;
	    $where = 3;
	}
    } else {
	print G $_;
    }
}
close(F);

rename($file2, $file);
