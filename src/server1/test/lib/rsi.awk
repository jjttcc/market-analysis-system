# Compute RSI - from Colby and Meyers
BEGIN {
if (n_value == 0) n_value = 7 # default n
n = n_value
}
/^#/ {next}
{
	closes [i++] = $4
	recs = i
}
END {
	upv = upsum(closes, 0, n) / n
	downv = downsum(closes, 0, n) / n
	printf("%f, %f, %f, %.5f\n", closes [n], upv, downv, rsi(upv / downv))
	for (j = n + 1; j < recs; ++j) {
		upv = (upv * (n-1) + rsidiff(closes[j], closes[j-1])) / n
		downv = (downv * (n-1) + rsidiff(closes[j-1], closes[j])) / n
		printf("%f, %f, %f, %.5f\n",
				closes [j], upv, downv, rsi(upv / downv))
	}
}

function rsi (rs)
{
	return 100 - (100 / (1 + rs))
}

# If v1 <= v2: 0; otherwise v1 - v2
function rsidiff(v1, v2) {
	return v1 <= v2? 0: v1 - v2
}

function upsum (arr, start, end)
{
	result = 0
	for (i = start + 1; i <= end; ++i)
	{
		if (closes [i] > closes [i-1])
		{
			result += closes [i] - closes [i-1]
		}
	}
	return result
}

function downsum (arr, start, end)
{
	result = 0
	for (i = start + 1; i <= end; ++i)
	{
		if (closes [i] < closes [i-1])
		{
			result += closes [i-1] - closes [i]
		}
	}
	return result
}
