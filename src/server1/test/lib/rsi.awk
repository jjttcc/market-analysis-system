# Compute RSI - from Colby and Meyers (alternate method)
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
	upavgs[0] = upsum(closes, 0, n) / n
	downavgs[0] = downsum(closes, 0, n) / n
	i = 1; j = n + 1
	for ( ; j < recs; ++j) {
		upavgs[i] = (upavgs[i-1] * (n-1) + rsidiff(closes[j], closes[j-1])) / n
		downavgs[i] = \
			(downavgs[i-1] * (n-1) + rsidiff(closes[j-1], closes[j])) / n
		++i
	}
	for (k = 0; k < i; ++k) {
		#printf("k: %d, %f, %f, %f\n", k,
		#	closes [k+n], upavgs[k], downavgs[k])
		printf("%f, %f, %f, %.5f\n", closes [k+n], upavgs[k], downavgs[k],
				rsi(upavgs[k] / downavgs[k]))
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
