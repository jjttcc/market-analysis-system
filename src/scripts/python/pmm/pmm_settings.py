# Settings for process_mas_mail script
# This is the file to edit to configure the settings so that process_mas_mail
# will work on your system.

# Path separator used by the operating system
path_sep = "/"
# Command-line based mail client program to use for sending mail
mailer = "mutt"
# Subject flag for mailer
subject_flag = "-s"
# Directory where the uptrend and downtrend files reside
list_file_directory = "/home2/finance/data/etc"
# Names of uptrend, downtrend, and sidelined files
uptrend_file_name = "up_watch"
downtrend_file_name = "down_watch"
sidelined_file_name = "sidelined"
# Strings flagging uptrend, downtrend, etc. watch lists in database
uptrend_flag = "uptrend"
downtrend_flag = "downtrend"
sidelined_flag = "sidelined"
# Strings specifying (regular expression) text matches:
long_term_string = ".*long-term.*"
# Event header
event_string = "Event for:"
# uptrend specifier
buy_string = ".*Uptrend"
# downtrend specifier
sell_string = ".*Downtrend"
# sideline specifier
sideline_string = ".*Sideways.*"
# regex string to match symbol from event line
symbol_regex = "Event for: *\([^,]*\),.*"
# string to use on event line to produce symbol from symbol_regex match
symbol_regsub = "\\1"
# regex string to match date (which must be mm/dd/yyyy) from event line
date_regex = ".*date: *\([^,]*\),.*"
# string to use on event line to produce date from date_regex match
date_regsub = "\\1"
