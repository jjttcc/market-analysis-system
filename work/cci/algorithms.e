class ALGORITHMS inherit

	BASIC_ROUTINES

feature -- experiment

	mdtp (tp, matp: ARRAY [REAL]; n, current_period_index: INTEGER): REAL is
			-- Mean Deviation of Typical Price
		local
			sum: REAL
			i: INTEGER
		do
			print ("(matp[" + current_period_index.out + "]: " +
				(matp @ current_period_index).out + "%N")
			from
				sum := 0
				i := current_period_index - n + 1
			until
				i = current_period_index + 1
			loop
				sum := sum + (tp @ i - matp @ current_period_index).abs
				i := i + 1
			end
			Result := sum / n
		end

	mdtp2 (tp: ARRAY [REAL]; n, current_period_index: INTEGER): REAL is
			-- Mean Deviation of Typical Price - calculates matp itself
		local
			sum, matp: REAL
			i: INTEGER
		do
			from
				from
					i := current_period_index - n + 1
					matp := 0
				until
					i = current_period_index + 1
				loop
					matp := matp + tp @ i
					i := i + 1
				end
				matp := matp / n
				print ("(matp[" + current_period_index.out + "]: " +
					matp.out + "%N")
				sum := 0
				i := current_period_index - n + 1
			until
				i = current_period_index + 1
			loop
				sum := sum + (tp @ i - matp).abs
				i := i + 1
			end
			Result := sum / n
		end

	test_matp is
		local
			tp, matp: ARRAY [REAL]
			n, curidx: INTEGER
		once
			tp := <<14.9990, 14.8102, 14.6529, 14.5833, 14.6811, 14.2249,
					13.9660, 14.3900, 14.3786, 14.4850, 14.6365, 14.5452,
					14.5706, 14.6330, 14.6854, 14.8697, 14.6504, 14.6074,
					14.4682, 14.4379, 14.1002, 14.0538, 14.2385, 14.3722,
					14.2769>>
			matp := <<0, 0, 0, 0, 14.7453, 14.5905, 14.4216, 14.3691, 14.3281,
					14.2889, 14.3712, 14.4871, 14.5232, 14.5741, 14.6142,
					14.6608, 14.6818, 14.6892, 14.6562, 14.6067, 14.4528,
					14.3335, 14.2597, 14.2405, 14.2083>>
			print ("tp.count, matp.count: " +
				tp.count.out + ", " +  matp.count.out + "%N")
			from
				n := 5; curidx := 5
			until curidx = tp.count + 1 loop
				print ("mdtp (tp, matp, " + n.out + ", " + curidx.out + ")%N")
				print (mdtp (tp, matp, n, curidx).out + "%N")
				print ("mdtp2 (tp, " + n.out + ", " + curidx.out + ")%N")
				print (mdtp2 (tp, n, curidx).out + "%N")
				curidx := curidx + 1
			end
		end

end
