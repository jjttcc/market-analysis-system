#!/usr/bin/perl -w

# Parse pre-/post-condition comments in Java files (of the form:
#	// Postcondition: tag: expression
# ) and insert the specified predicates into the code.  Assume that
# the (Java) Logic class is available and that the the class being
# processed "implements" AssertionConstants.
#!!!!Include the description of the expected format here.

#!!!!Remember to process "implies".

package assertion_tools;

my $post;
my $pre;
my $postconditions = "";
my $preconditions = "";
my $in_function = 0;
my $start_function;
my $open_braces = 0;
my $close_braces = 0;
my $obrace = "{";
my $cbrace = "}";
my $print_current_line;

my @lines = (<>);
my $line_count = @lines;
my $current_line = 0;
my @assertions;

while ($current_line < $line_count) {
	$_ = $lines[$current_line];
	$post = 0;
	$pre = 0;
	$start_function = 0;
	$print_current_line = 1;
	@assertions = ();
	if (! $in_function) {
		if (/\/\/ *Precondition:/) {
			@assertions = extracted_assert_fields();
			$pre = 1;
		} elsif (/\/\/ *Postcondition:/) {
			@assertions = extracted_assert_fields();
			$post = 1;
		}
		if (beginning_of_function($_)) {
			if (! /class/) {
				$in_function = 1;
				++$open_braces;
				$start_function = 1;
			}
		}
	} else {
		$open_braces += substr_count($_, $obrace);
		$close_braces += substr_count($_, $cbrace);
		if ($open_braces == $close_braces) {
			$in_function = 0;
			print $postconditions;
			$postconditions = "";
		}
	}
	if ($print_current_line) {
		print;
	}
	if ($start_function) {
		print $preconditions;
		$preconditions = "";
	}
	if ($post) {
		$postconditions .= processed_postcondition(@assertions);
	}
	if ($pre) {
		$preconditions .= processed_precondition(@assertions);
	}
	++$current_line;
}

# The specified assertion line, processed as Java code.
sub processed_assertion {
	my $label = $_[0];
	my $line = $_[1];
	my $result = "";
	my $tag = "";
	my $expr = "";
	$line =~ /([^:]*):* *(.*)$/;
	if ($1 ne "") {
		if ($2 ne "") {
			$tag = $1;
			$expr = $2;
		} else {
			$expr = $1;
		}
		$result = "\t\tassert " . $expr . ": " . $label;
		if ($tag ne "") {
			$result = $result . " + \"" . ": " . $tag . "\""
		}
	}
	$result .= ";\n";
	return $result;
}

# Treat each argument as a line: For lines 2 .. n, if the line has the
# same number of leading spaces as the first line, treat it as a separate
# assertion; otherwise, append it to the previous assertion.  Return the
# resulting array.
sub separate_assertions {
	my $count = @_;
	my $pattern = ".*\/\/([ \t]*)[^ \t]";
	if ($count == 0) { return; }
	my @result = stripped_spaces_slashes($_[0]);
	if ($count > 1) {
		my $leading_space = "";
		my $l = $_[0];
		$l =~ /$pattern/;
		$leading_space = $1;
		for (my $i = 1; $i < $count; ++$i) {
			$l = $_[$i];
			$l =~ /$pattern/;
			# If the 'leading white space' (with comment //) of the
			# first line is the same as that of the current line,
			# store the assertion as a seprate assertion.  Otherwise, append
			# the assertion to the last element of @result.
			if ($1 eq $leading_space) {
				push(@result, stripped_spaces_slashes($_[$i]));
			} else {
				$result[$#result] .= " " . stripped_spaces_slashes($_[$i]);
			}
		}
	}
	return @result;
}

# Extract assertion-specification fields for the current Pre- or Post-
# condition specification.
sub extracted_assert_fields {
	#!!!!Not used, remove(?):
	my $expr_on_next_line = 0;
	my @assert_lines = ();
	my $l = "";
	if ($_ =~ /tion:[ \t]*$/) {
		$expr_on_next_line = 1;
	} else {
		$l = $_;
		$l =~ s/.*P[ro][a-z]*condition:[ \t]*//;
		chomp $l;
		@assert_lines = ($l);
	}
	if ($current_line < $line_count) {
		while ($current_line < $line_count) {
			$l = $lines[$current_line + 1];
			chomp $l;
#print "Checking " . $l . "\n";
			# If $l, the next line, is not a new assertion and not the
			# beginning of a function,
			if (! (beginning_of_assertion($l) || beginning_of_function($l))) {
				push(@assert_lines, $l);
#print "not boa or bof: " . $l;
				# Print the current line here because the $print_current_line
				# flat will instruct the main loop to skip it.
				print $lines[$current_line];
				++$current_line;
				$print_current_line = 0;
			} else {
				# End of current assertion spec. - break out of loop.
				last;
			}
		}
	}
	if (! $print_current_line) {
		# Due to the above processing, the 'current line' needs to be
		# printed.
		print $lines[$current_line];
	}
	return separate_assertions(@assert_lines);
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

# Is 'line' the beginning of a function definition?
sub beginning_of_function {
	$line = $_[0];
	$result = 0;
	if ($line =~ /{[ \t]*$/) {
		$result = 1;
	}
	return $result;
}

# Is 'line' the beginning of a pre- or post-condition specification?
sub beginning_of_assertion {
	$line = $_[0];
	$result = 0;
	if ($line =~ /\/\/ *P[ro][a-z]*condition:/) {
		$result = 1;
	}
	return $result;
}

sub assertions {
	my $label = $_[0];

	my $i = 1;
	my $result = "";
	while ($i < @_) {
		$result .= processed_assertion($label, $_[$i]);
		++$i;
	}
	return $result;
}

sub processed_postcondition {
	return assertions("POSTCONDITION", @_);
}

sub processed_precondition {
	return assertions("PRECONDITION", @_);
}

# Argument stripped of preceding /s and white space
sub stripped_spaces_slashes {
	$result = $_[0];
	$result =~ s/^[ \t]*\/\/[ \t]*//;
	return $result;
}
#Remove!!!!!!!!!!:
				# Process $l as the remainder of the current assertion.
#				$l =~ s/^[ \t]*\/\/[ \t]*//;
#				$exprs .= " " . $l;
				# Since the assertion is being processed here, make the
				# ... next line the current line.
