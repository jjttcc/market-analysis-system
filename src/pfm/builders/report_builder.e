note
	description: "Builder of all reports to be executed"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class REPORT_BUILDER inherit

	FACTORY

feature -- Access

	product: LIST [REPORT]
			-- All reports to be executed

feature -- Basic operations

	execute
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
