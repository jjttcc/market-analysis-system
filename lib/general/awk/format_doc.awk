# Tools for formatting/converting documents

# Convert a special "*^..." directive.
function convert_directive(s) {
	gsub(/\*\^font/, "\\f", s)
	gsub(/\*\^em/, "\\&#8212;", s)
	return s
}

