/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;

/**
 *  Font properties used by the application
 */
abstract public class FontProperties {
	public static final void main(String[] args) {
		System.out.println("testing fonts");

		String[] fonts = { DIALOG, DIALOGINPUT, MONOSPACED, SERIF, SANSSERIF,
			HELVETICA_BOLD, HELVETICA_ITALIC, PALATINO_BOLD, PALATINO_ITALIC
		};
		for (int i = 0; i < fonts.length; ++i) {
			Font f = new Font(fonts[i], Font.PLAIN, 10);
			System.out.println("f: " + f);
			System.out.println("f.style(): " + f.getStyle());
		}
	}

	public static final String DIALOG = "Dialog";
	public static final String DIALOGINPUT = "DialogInput";
	public static final String MONOSPACED = "Monospaced";
	public static final String SERIF = "Serif";
	public static final String SANSSERIF = "SansSerif";
	public static final String HELVETICA_PLAIN = "Helvetica Plain";
	public static final String HELVETICA_BOLD = "Helvetica Bold";
	public static final String HELVETICA_ITALIC = "Helvetica Italic";
	public static final String PALATINO_PLAIN = "Palatino Plain";
	public static final String PALATINO_BOLD = "Palatino Bold";
	public static final String PALATINO_ITALIC = "Palatino Italic";

}
