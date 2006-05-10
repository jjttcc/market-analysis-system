indexing
	description:
		"Dummy/fake thread class - For non-multi-threaded version"
	author: "Jim Cochrane"
	date: "$Date: 2006-04-09 16:12:50 -0600 (Sun, 09 Apr 2006) $";
	revision: "$Revision: 4345 $"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class THREAD inherit

feature

	launch is
		do
			execute
		end

	execute is
		deferred
		end

end
