# Compute RSI
BEGIN {
n = 7
}
{
	closes [i++] = $4
	recs = i
}
END {
	for (j = n; j < recs; ++j)
	{
		upv = upavg(closes, j - n, j)
		downv = downavg(closes, j - n, j)
		printf("%f, %f, %f, %.5f\n",
				closes [j], upv, downv, rsi(upv / downv))
	}
}

function rsi (rs)
{
	return 100 - (100 / (1 + rs))
}

function upavg (arr, start, end)
{
	upsum = 0
	for (i = start + 1; i <= end; ++i)
	{
		#print closes [i] ", " closes [i-1]
		if (closes [i] > closes [i-1])
		{
			upsum += closes [i] - closes [i-1]
		}
	}
	#print "end, start: " end ", " start ", upsum: " upsum
	return upsum / (end - start)
}

function downavg (arr, start, end)
{
	downsum = 0
	for (i = start + 1; i <= end; ++i)
	{
		#print closes [i] ", " closes [i-1]
		if (closes [i] < closes [i-1])
		{
			downsum += closes [i-1] - closes [i]
		}
	}
	#print "end, start: " end ", " start ", downsum: " downsum
	return downsum / (end - start)
}
