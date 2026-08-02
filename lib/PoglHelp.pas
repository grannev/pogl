unit PoglHelp;

interface

procedure WriteHelp;

implementation

procedure WriteHelp;
begin
	writeln('This is the POGL render. Usage:');
	writeln(); write('    ');
	writeln('pogl [file] [xyz-k] [glob-k] [point-size]');
	writeln(); writeln();
	
	writeln('Description of pogl arguments');
	writeln(); write('    ');
	writeln('[file] - Name of Wavefron obj file. Other format is invalid');
	writeln(); write('    ');
	writeln('[xyz-k] - Coefficient of XYZ coords. Big K = Big Quality');
	writeln(); write('    ');
	writeln('[glob-k] - Coefficient of Space Area. Big K = Big Visibility');
	writeln(); write('    ');
	writeln('[point-size] - Size of the "brush"');
	writeln(); writeln();

	writeln('Program GUI usage');
	writeln(); write('    ');
	writeln('Arrow, PageUp, PageDown keys - rotate Object');
	writeln(); write('        ');
	writeln('LeftArrow - Rotate anticlockwise around Y-axis');
	writeln(); write('        ');
	writeln('RightArrow - Rotate clockwise around Y-axis');
	writeln(); write('        ');
	writeln('DownArrow - Rotate anticlockwise around X-axis');
	writeln(); write('        ');
	writeln('UpArrow - Rotate clockwise around X-axis');
	writeln(); write('        ');
	writeln('PageUp - Rotate anticlockwise around Z-axis');
	writeln(); write('        ');
	writeln('PageDown - Rotate clockwise around Z-axis');
	writeln(); write('    ');
	writeln('Home key - Stop rotating object');
	writeln(); write('    ');
	writeln('Esc key - Exit from programm');
	writeln(); writeln();

	writeln('All about this programm write to <eqorrannev@gmail.com>');
	writeln('                                 <https://t.me/grannev>');
end;

end.

