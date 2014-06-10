note
	description: "Child of THREAD - test/experiment 1"
	author: "Jim Cochrane"
	date: "$Date: 2006-04-04 19:10:39 -0600 (Tue, 04 Apr 2006) $";
	revision: "$Revision: 4327 $"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class THREAD_CHILD_1 inherit

	THREAD

feature

	execute
		local
			i: INTEGER
		do
			from
				i := 0
			until
				i > 99
			loop
				print ("I am a thread ([" + i.out + "]" + Current.out +
					") and I am having fun.%N")
				i := i + 1
			end
			print ("Finished having fun - sleeping for a while ...." + "%N")
			sleep (12000000000)
			print ("Finished living - I die ...." + "%N")
		end

end
