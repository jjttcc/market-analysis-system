/* Copyright 1998, 1999: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;

/** Root class for the Market Analysis client process */
public class MA_Client
{
	public static void main(String[] args) throws IOException
	{
		MA_Connection connection = new MA_Connection(args);
		MA_Chart chart = new MA_Chart(connection);
	}
}
