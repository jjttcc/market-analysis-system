/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.io.*;
import java.net.*;

/** Root class for the Market Analysis client process */
public class MA_Client
{
	public static void main(String[] args) throws IOException
	{
		DataSetBuilder data_builder = new DataSetBuilder(args);
		Chart chart = new Chart(data_builder);
	}
}
