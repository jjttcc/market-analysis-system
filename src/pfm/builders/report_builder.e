indexing
	description: "Builder of all reports to be executed"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class REPORT_BUILDER inherit

	FACTORY

feature -- Access

	product: LIST [REPORT]
			-- All reports to be executed

feature -- Basic operations

	execute is
			-- Create the reports
		local
			report: REPORT
		do
			create {LINKED_LIST [REPORT]} product.make
--			create {BASIC_REPORT} report.make
--			product.extend (report)
			create {CAPITAL_GAINS_AND_LOSSES_REPORT} report.make
			product.extend (report)
		end

end -- REPORT_BUILDER
