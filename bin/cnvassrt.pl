#!/usr/bin/perl -w

# Parse pre-/post-condition comments in Java files and
# insert the specified predicates into the code.  Assume that
# the (Java) Logic class is available and that the the class being
# processed "implements" AssertionConstants.
# Expected format:
#	// P{ost|re}condition: <tag>: <expression>
# where "tag:" is optional and "<tag>: <expression>" can be on the next
# line, and extend over several lines.  Alternatively, there can be more
# than one set of "<tag>: <expression>", but they need to be indented by
# the same amount to be recognized as separate assertions.

package assertion_tools;

my $Logic_class_name = "Logic";

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
		if (return_at_end_found() || $open_braces == $close_braces) {
			$in_function = 0;
			print $postconditions;
			$postconditions = "";
			$open_braces = 0;
			$close_braces = 0;
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
		$postconditions .= processed_postconditions(@assertions);
	}
	if ($pre) {
		$preconditions .= processed_preconditions(@assertions);
	}
	++$current_line;
}

# Is the current line a return statement and is it the last statement
# before the end of the current routine?
sub return_at_end_found {
	$result = 0;
	if ($_ =~ /\breturn\b/ && $open_braces == $close_braces + 1) {
		for (my $i = 1; $i < $line_count; ++$i) {
			if ($lines[$current_line + $i] =~ /^\s*\/\//) {
				# Ignore comment lines.
			} elsif (! ($lines[$current_line + $i] =~ /^\s*$/)) {
				if ($lines[$current_line + $i] =~ /^\s*$cbrace\s*$/) {
					$result = 1;
				} else {
					# Statement found after return - leave with
					# $result == 0.
				}
				last;
			}
		}
	}
	return $result;
}

# "implies" expression processed for Java - Assume "implies" occurs only
# once.
sub processed_implication {
	$expr = $_[0];
	$expr =~ /(.*)[ \t]+implies[ \t]+(.*)/;
	# For now, just assume that everything to the left of "implies" is
	# its left operator and everything to the right is the right operator.
	# May want to cover more complex experssions in the future.
	return $Logic_class_name . ".implies(" . $1 . ", " . $2 . ")";
}

sub post_processed_expr {
	my $expr = $_[0];
	$result = $expr;
	if ($expr =~ /[ \t]implies[ \t]/) {
		$result = processed_implication($expr);
	}
	return $result;
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
		$expr = post_processed_expr($expr);
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
	my @assert_lines = ();
	my $l = "";
	if ($_ =~ /tion:[ \t]*$/) {
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

sub processed_postconditions {
	return assertions("POSTCONDITION", @_);
}

sub processed_preconditions {
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
