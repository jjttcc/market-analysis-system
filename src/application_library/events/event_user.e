indexing
	description: "Abstraction for a user who is an event registrant"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

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

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		rename
			event_types as global_event_types
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (event_history_file_name: STRING) is
		do
			hfile_name := event_history_file_name
			u_make
			er_make
			-- Object comparison is required because of the persistence
			-- mechanism - on retrieval from storage a member of `event_types'
			-- may be a different instance than the respective member of
			-- `global_event_types'.  (Originally they will be the same
			-- instance.)
			event_types.compare_objects
		end

feature -- Basic operations

	perform_notify (elist: LIST [TYPED_EVENT]) is
		local
			msg: STRING
			e: TYPED_EVENT
		do
			if not email_addresses.empty and mailer /= Void then
				!!msg.make (elist.count * 120)
				from
					elist.start
				until
					elist.exhausted
				loop
					e := elist.item
					msg.append (concatenation (<<"Event name: ",
								e.name, ", time stamp: ",
								e.time_stamp, ", type: ", e.type.name,
								"%Ndescription: ", e.description, "%N%N">>))
					elist.forth
				end
				notify_by_email (msg, concatenation (<<elist.count,
								" TA Events Received at ", current_date,
								", ", current_time>>))
			else
				if email_addresses.empty then
					print (concatenation (<<"User ", name,
							" has no email address set.%N">>))
				else
					check
						mailer_void: mailer = Void
					end
					print (concatenation (<<"User ", name,
							" has no mailer set.%N">>))
				end
			end
		end

end -- EVENT_USER
