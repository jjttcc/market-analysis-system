import java.util.*;

/** Global configuration settings */
public class Configuration implements NetworkProtocol
{
	public String session_settings()
	{
		StringBuffer result = new StringBuffer();
		int i;
		DateSetting ds;

		for (i = 0; i < start_date_settings.size() - 1; ++i)
		{
			ds = (DateSetting) start_date_settings.elementAt(i);
			result.append(Start_date + "\t" + ds.time_period() + "\t" +
							ds.date() + "\t");
		}
		ds = (DateSetting) start_date_settings.elementAt(i);
		result.append(Start_date + "\t" + ds.time_period() + "\t" +
						ds.date());
		if (end_date_settings.size() > 0)
		{
			result.append("\t");
			for (i = 0; i < end_date_settings.size() - 1; ++i)
			{
				ds = (DateSetting) end_date_settings.elementAt(i);
				result.append(End_date + "\t" + ds.time_period() + "\t" +
								ds.date() + "\t");
			}
			ds = (DateSetting) end_date_settings.elementAt(i);
			result.append(End_date + "\t" + ds.time_period() + "\t" +
							ds.date());
		}
		return result.toString();
	}

	public static Configuration instance()
	{
		return _instance;
	}

	protected Configuration()
	{
		start_date_settings = new Vector();
		end_date_settings = new Vector();

		//!!!For now, just hard code (daily) settings.
		DateSetting ds = new DateSetting("1999/03/01", daily_period_type);
		start_date_settings.addElement(ds);
		ds = new DateSetting("now", daily_period_type);
		end_date_settings.addElement(ds);
	}

	private static final Configuration _instance = new Configuration();

x
	private Vector start_date_settings;
	private Vector end_date_settings;

	private class DateSetting
	{
		DateSetting(String dt, String period)
		{
			_date = dt; _time_period = period;
		}

		public String date() { return _date; }
		public String time_period() { return _time_period; }

		private String _date;
		private String _time_period;
	}
}
