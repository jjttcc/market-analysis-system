indexing
	description: "Abstraction for a user who is an event registrant"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class EVENT_USER inherit

	USER
		rename
			make as u_make
		export {NONE}
			u_make
		end

	MARKET_EVENT_REGISTRANT
		rename
			make as er_make
		export {NONE}
			er_make
		end

	GLOBAL_APPLICATION
		rename
			event_types as global_event_types
		export {NONE}
			all
		end

	DATE_TIME_SERVICES
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (event_history_file_name, field_sep, record_sep: STRING) is
		require
			not_void: field_sep /= Void and record_sep /= Void
		do
			hfile_name := event_history_file_name
			field_separator := field_sep
			record_separator := record_sep
			u_make
			er_make
			-- Object comparison is required because of the persistence
			-- mechanism - on retrieval from storage a member of `event_types'
			-- may be a different instance than the respective member of
			-- `global_event_types'.  (Originally they will be the same
			-- instance.)
			event_types.compare_objects
		ensure
			hfilename_set: hfile_name = event_history_file_name
			separators_set: field_separator = field_sep and
				record_separator = record_sep
		end

feature -- Basic operations

	perform_notify (elist: LIST [MARKET_EVENT]) is
			-- Notify user of events in `elist' or log the error
			-- if notification failed.
		local
			msg: STRING
			e: MARKET_EVENT
		do
			if not email_addresses.empty and mailer /= Void then
				create msg.make (elist.count * 120)
				from
					elist.start
				until
					elist.exhausted
				loop
					e := elist.item
					msg.append (event_information (e))
					msg.append ("%N%N")
					elist.forth
				end
				notify_by_email (msg, concatenation (<<elist.count,
					" TA Events Received at ", current_date, ", ",
					current_time, " (Notification to ", name, ")">>))
			else
				if email_addresses.empty then
					log_errors (<<"User ", name,
						" has no email address set.%N">>)
				else
					check
						mailer_void: mailer = Void
					end
					log_errors (<<"User ", name,
						" has no mailer set.%N">>)
				end
			end
			if last_error /= Void then
				log_errors (<<"Notification to user ", name,
					" failed with error: ", last_error, "%N">>)
			end
		end

end -- EVENT_USER
