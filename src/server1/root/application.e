note
	description : "covariance_experiment1 application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature -- Access

	demo1: MANAGER

	demo2: MANAGER

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			sm1: SIDEMAN_ONE [TYPEA]
			sm2: SIDEMAN_TWO [TYPEB]
			ta: TYPEA
			tb: TYPEB
		do
print("%N%NCopy these files to the mas project and incorporate them to see " +
"if they%Nwork there.%N")
			create ta.make
			create tb.make
			create sm1.make(ta)
			create sm2.make(tb)
			print ("Hello Eiffel World!%N")
			create demo1.make(create {PRINCIPAL_ONE}.make(sm1))
			create demo2.make(create {PRINCIPAL_TWO}.make(sm2))
			demo1.execute
			demo2.execute
		end

end
