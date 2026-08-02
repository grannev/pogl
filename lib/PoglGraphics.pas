unit PoglGraphics;

interface

uses PoglArgs, PoglModel, PoglColors, PoglWindowSize, PoglMath;

type
	TPixel = longword;
	TFrameBuffer = array 
	[1..poglMainWindowSize] of TPixel;

var
	frameBuffer: TFrameBuffer;
	globArgs: TPoglArgs;

procedure PoglPrepareGraphics(const args: TPoglArgs);
procedure PoglClearScreen(pixel: TPixel);
procedure PoglPutPixel(x, y: integer; pixel: TPixel);
procedure PoglDrawObjModel(const model: TObjModel);

implementation

procedure PoglPrepareGraphics(const args: TPoglArgs);
begin
	globArgs := args;
end;

procedure PoglClearScreen(pixel: TPixel);
var
	i: longint;
begin
	for i := 1 to poglMainWindowSize do
		frameBuffer[i] := pixel;
end;

procedure PoglPutPixel(x, y: integer; pixel: TPixel);
var
	index: longint;
begin
	x := poglMainWindowWidth div 2 + x;
	y := poglMainWindowHeight div 2 - y;

	if (x < 0) or (x >= poglMainWindowWidth) or
	   (y < 0) or (y >= poglMainWindowHeight) then
		exit;

	index := longint(y) * poglMainWindowWidth + x + 1;
	frameBuffer[index] := pixel;
end;

procedure PoglDrawObjModel(const model: TObjModel);
var
	x, y, i: integer;
	scale: single;
begin
	scale := MinSingle(
		globArgs.width / (model.vmax.x - model.vmin.x),
		globArgs.height / (model.vmax.y - model.vmin.y)
	);

	for i := 0 to high(model.rotatedVerteces) do begin
		x := round((model.rotatedVerteces[i].x - model.center.x) * scale);
		y := round((model.rotatedVerteces[i].y - model.center.y) * scale);

		PoglPutPixel(x, y, colorWhite);
	end;
end;

end.
