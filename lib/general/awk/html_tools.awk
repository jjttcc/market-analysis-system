# html-related tools

# Convert special html characters for non-html documents.
function convert_html_chars(s) {
	gsub(/\&lt;/, "<", s)
	gsub(/\&gt;/, ">", s)
	gsub(/\&nbsp;/, " ", s)
	gsub(/\&#8212;/, "-", s)
	return s
}

