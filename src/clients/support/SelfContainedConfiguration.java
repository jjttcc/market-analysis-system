/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package support;

/** Self-contained configuration settings (rather than reading from
 * .ma_clientrc */
public class SelfContainedConfiguration {

// Access

	// All configuration settings
	public static String contents() {
		return
"start_date\tdaily\tnow - 9 months\n" +
"end_date\tdaily\tnow\n" +
"start_date\thourly\t2000/07/01\n" +
"start_date\t30-minute\t2000/08/01\n" +
"start_date\t15-minute\t2000/08/14\n" +
"start_date\t10-minute\t2000/08/14\n" +
"start_date\t5-minute\t2000/08/14\n" +
"start_date\tweekly\tnow - 4 years\n" +
"start_date\tmonthly\tnow - 8 years\n" +
"start_date\tquarterly\tnow - 20 years\n" +
"upper_indicator\tSimple Moving Average\tdarkGreen\n" +
"upper_indicator\tExponential Moving Average\tdarkBlue\n" +
"lower_indicator\tMACD Difference\tred\n" +
"lower_indicator\tMACD Signal Line (EMA of MACD Difference)\tlightBlue\n" +
"lower_indicator\tMACD Histogram\tblack\n" +
"lower_indicator\tSlope of MACD Signal Line\tdarkGreen\n" +
"lower_indicator\tSlope of Slope of MACD Signal Line\tmagenta\n" +
"lower_indicator\tStochastic %D\n" +
"lower_indicator\tSlow Stochastic %D\tmagenta\n" +
"lower_indicator\tStochastic %K\tgray\n" +
"lower_indicator\tVolume\n" +
"lower_indicator\tOpen interest\tblack\n" +
"lower_indicator\tOn Balance Volume\tdarkBlue\n" +
"lower_indicator\tAccumulation/Distribution\tred\n" +
"lower_indicator\tEMA of Volume\tdarkGray\n" +
"lower_indicator\tSlope of EMA of Volume\tgray\n" +
"lower_indicator\tEMA of Open interest\tdarkGray\n" +
"lower_indicator\tSlope of EMA of Open interest\tgray\n" +
"lower_indicator\tMomentum\toliveGreen\n" +
"lower_indicator\tRate of Change\tdarkGray\n" +
"lower_indicator\tWilliams %R\tyellow\n" +
"lower_indicator\tRelative Strength Index\tred\n" +
"lower_indicator\tSlope of MACD Signal Line Trend\tred\n" +
"lower_indicator\tSlope of Slope of MACD Signal Line Trend\tblue\n" +
"lower_indicator\t[Slope of MACD, Slope of Slope of MACD] Trend\tred\n" +
"lower_indicator\tWMA of Midpoint\toliveGreen\n" +
"lower_indicator\tWMA of Midpoint 2\tred\n" +
"lower_indicator\tMidpoint\tgray\n" +
"lower_indicator\tMACD of Volume\tblue\n" +
"lower_indicator\tMACD of OBV\tgray\n" +
"lower_indicator\tclose\tgreen\n" +
"lower_indicator\tNo lower indicator\n" +
"lower_indicator\tNo upper indicator\n" +
"indicator_line_h\tStochastic %K\t80 80\n" +
"indicator_line_h\tStochastic %K\t20 20\n" +
"indicator_line_h\tStochastic %D\t80 80\n" +
"indicator_line_h\tStochastic %D\t20 20\n" +
"indicator_line_h\tSlow Stochastic %D\t80 80\n" +
"indicator_line_h\tSlow Stochastic %D\t20 20\n" +
"indicator_line_h\tMACD Difference\t0 0\n" +
"indicator_line_h\tSlope of MACD Difference\t0 0\n" +
"indicator_line_h\tSlope of Slope of MACD Difference\t0 0\n" +
"indicator_line_h\tSlope of Slope of Slope of MACD Difference\t0 0\n" +
"indicator_line_h\tSlope of EMA\t0 0\n" +
"indicator_line_h\tSlope of Slope of EMA\t0 0\n" +
"indicator_line_h\tSlope of Slope of Slope of EMA\t0 0\n" +
"indicator_line_h\tSlope of Slope of Slope of Slope of EMA\t0 0\n" +
"indicator_line_h\tMACD Signal Line (EMA of MACD Difference)\t0 0\n" +
"indicator_line_h\tMACD Histogram\t0 0\n" +
"indicator_line_h\tSlope of MACD Signal Line\t0 0\n" +
"indicator_line_h\tSlope of Slope of MACD Signal Line\t0 0\n" +
"indicator_line_h\tSlope of Price\t0 0\n" +
"indicator_line_h\tSlope of Slope of Price\t0 0\n" +
"indicator_line_h\tSlope of Slope of Slope of Price\t0 0\n" +
"indicator_line_h\tSlope of Slope of Slope of Slope of Price\t0 0\n" +
"indicator_line_h\tMomentum\t0 0\n" +
"indicator_line_h\tSlope of EMA of Volume\t0 0\n" +
"indicator_line_h\tSlope of EMA of Open interest\t0 0\n" +
"indicator_line_h\tRate of Change\t1 1\n" +
"indicator_line_h\tRelative Strength Index\t30 30\n" +
"indicator_line_h\tRelative Strength Index\t70 70\n" +
"indicator_line_h\t[Slope of MACD, Slope of Slope of MACD] Trend\t0 0\n" +
"indicator_line_h\t[Slope of MACD, Slope of Slope of MACD] Trend\t1 1\n" +
"indicator_line_h\t[Slope of MACD, Slope of Slope of MACD] Trend\t-1 -1\n" +
"indicator_line_h\tSlope of MACD Signal Line Trend\t0 0\n" +
"indicator_line_h\tSlope of Slope of MACD Signal Line Trend\t0 0\n" +
"indicator_line_h\tMACD of Volume\t0 0\n" +
"indicator_line_h\tMACD of OBV\t0 0\n" +
"background_color\tpink\n" +
"black_candle_color\tred\n" +
"white_candle_color\toliveGreen\n" +
"stick_color\tblack\n" +
"bar_color\tdarkGreen\n" +
"line_color\tdarkBlue\n" +
"text_color\tblack\n" +
"reference_line_color\tsoftBlue\n" +
"main_graph_style\tcandle\n" +
"indicator_group\n" +
"MACD Difference\n" +
"MACD Signal Line (EMA of MACD Difference)\n" +
"MACD Histogram\n" +
"Slope of MACD Signal Line\n" +
"Slope of Slope of MACD Signal Line\n" +
"Slope of MACD Signal Line Trend\n" +
"Slope of Slope of MACD Signal Line Trend\n" +
"[Slope of MACD, Slope of Slope of MACD] Trend\n" +
"end_block\n" +
"indicator_group\n" +
"EMA of Volume\n" +
"Volume\n" +
"end_block\n" +
"indicator_group\n" +
"Open interest\n" +
"EMA of Open interest\n" +
"end_block\n" +
"indicator_group\n" +
"EMA of Open interest\n" +
"Open interest\n" +
"end_block\n" +
"indicator_group\n" +
"Stochastic %K\n" +
"Stochastic %D\n" +
"Slow Stochastic %D\n" +
"end_block\n";
	}
}
