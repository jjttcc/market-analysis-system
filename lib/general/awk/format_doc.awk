# Tools for formatting/converting documents

# Convert a special "*^..." directive.
function convert_directive() {
	gsub(/\*\^font/, "\\f")
	gsub(/\*\^em/, "\\&#8212;")
}

