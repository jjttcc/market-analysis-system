#!/usr/bin/perl -w

# Parse pre-/post-condition comments in Java files (of the form:
#	// Postcondition: tag: expression
# ) and insert the specified predicates into the code.  Assume that
# the (Java) Logic class is available and that the the class being
# processed "implements" AssertionConstants.
#!!!!Include the description of the expected format here.

package assertion_tools;

my $tag = "";
my $expr = "";
my $post;
my $pre;
my $postconditions = "";
my $preconditions = "";
my $in_function = 0;
my $start_function;
my $open_braces = 0;
my $close_braces = 0;

while (<>) {
	$post = 0;
	$pre = 0;
	$start_function = 0;
	if (! $in_function) {
		if (/\/\/ *Precondition: *([^:]*):* *(.*)$/) {
			extract_assert_fields();
			$pre = 1;
		} elsif (/\/\/ *Postcondition: *([^:]*):* *(.*)$/) {
			extract_assert_fields();
			$post = 1;
		}
		if (/{[ \t]*$/) {
			if (! /class/) {
				$in_function = 1;
				++$open_braces;
				$start_function = 1;
			}
		}
	} else {
		$open_braces += substr_count($_, "{");
		$close_braces += substr_count($_, "}");
#		print "ob, cb: " . $open_braces . ", " . $close_braces;
		if ($open_braces == $close_braces) {
			$in_function = 0;
			print $postconditions;
			$postconditions = "";
		}
	}
	print;
	if ($start_function) {
		print $preconditions;
		$preconditions = "";
	}
	if ($post) {
		$postconditions .= postcondition($expr, $tag) . "\n";
	}
	if ($pre) {
		$preconditions .= precondition($expr, $tag) . "\n";
	}
}

sub extract_assert_fields {
	if ($1 ne "") {
		if ($2 ne "") {
			$tag = $1;
			$expr = $2;
		} else {
			$expr = $1;
		}
	}
	chomp $expr;
}

# Number of times arg2 occurs within arg2
sub substr_count {
	my $s = $_[0];
	my $subs = $_[1];
	my $result = 0;
	my $index = index($s, $subs);
	while ($index != -1) {
		++$result;
		$index = index($s, $subs, $index + 1);
		
	}
	return $result;
}

sub assertion {
	my $expr_part = $_[0];
	my $label = $_[1];
	my $tag_part = $_[2];

	my $result = "\t\tassert " . $expr_part . ": " . $label;
	if ($tag_part ne "") {
		$result = $result . " + \"" . $tag_part . "\""
	}
	$result = $result . ";";
	return $result;
}

sub postcondition {
	return assertion($_[0], "POSTCONDITION", $_[1]);
}

sub precondition {
	return assertion($_[0], "PRECONDITION", $_[1]);
}
