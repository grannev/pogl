unit PoglColors;

interface

type
	TColor = longword;

const
	colorBlack = $FF000000;
	colorWhite = $FFFFFFFF;
	colorGray = $FF808080;
	colorSilver = $FFC0C0C0;

	colorRed = $FFFF0000;
	colorGreen = $FF008000;
	colorBlue = $FF0000FF;
	colorYellow = $FFFFFF00;
	colorCyan = $FF00FFFF;
	colorMagenta = $FFFF00FF;
	colorLime = $FF00FF00;

	colorOrange = $FFFFA500;
	colorPurple = $FF800080;
	colorPink = $FFFFC0CB;
	colorTeal = $FF008080;
	colorNavy = $FF000080;
	colorMaroon = $FF800000;
	colorOlive = $FF808000;

	colorGold = $FFFFD700;
	colorCoral = $FFFF7F50;
	colorSkyBlue = $FF87CEEB;
	colorViolet = $FFEE82EE;
	colorBrown = $FFA52A2A;
	colorTurquoise = $FF40E0D0;
	colorIndigo = $FF4B0082;
	colorSalmon = $FFFA8072;
	colorKhaki = $FFF0E68C;

function PoglRandomColor: TColor;

implementation

const
	colors: array [0..19] of TColor = (
		colorRed,
		colorGreen,
		colorBlue,
		colorYellow,
		colorCyan,
		colorMagenta,
		colorLime,
		colorOrange,
		colorPurple,
		colorPink,
		colorTeal,
		colorOlive,
		colorGold,
		colorCoral,
		colorSkyBlue,
		colorViolet,
		colorBrown,
		colorTurquoise,
		colorSalmon,
		colorKhaki
	);

function PoglRandomColor: TColor;
begin
	PoglRandomColor := colors[random(length(colors))];
end;

initialization
	randomize;

end.
