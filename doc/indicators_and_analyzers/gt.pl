#!/usr/bin/perl -n
# Duplicate mas output for testing: Is the current value > last period's value?
# If so, print 1, elsex print 0

chomp;
@line = split("\t", $_);
$n = @line[1];
$date = @line[0];
if ($n > $oldn) { $value = 1; } else { $value = 0; }
$oldn = $n;
print "$date\t$value\n";
