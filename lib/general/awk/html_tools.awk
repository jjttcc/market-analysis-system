# html-related tools

# Convert special html characters for non-html documents.
function convert_html_chars() {
	gsub(/\&lt;/, "<")
	gsub(/\&gt;/, ">")
	gsub(/\&nbsp;/, " ")
	gsub(/\&#8212;/, "-")
}

