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
	screenVerteces: TScreenVertexArray;
	moveX, moveY: single;

procedure PoglPrepareGraphics(const args: TPoglArgs);
procedure PoglClearScreen(pixel: TPixel);
procedure PoglPutPixel(x, y: integer; pixel: TPixel);
procedure PoglDrawObjModel(const model: TObjModel);

implementation

procedure PoglPrepareGraphics(const args: TPoglArgs);
begin
	globArgs := args;
	moveX := 0;
	moveY := 0;
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

procedure PoglDrawLine(
	x0, y0, x1, y1: integer;
	pixel: TPixel);
var
	deltaX, deltaY: integer;
	stepX, stepY: integer;
	errorValue, errorDouble: integer;
begin
	deltaX := abs(x1 - x0);
	deltaY := -abs(y1 - y0);

	if x0 < x1 then
		stepX := 1
	else
		stepX := -1;

	if y0 < y1 then
		stepY := 1
	else
		stepY := -1;

	errorValue := deltaX + deltaY;

	while true do begin
		PoglPutPixel(x0, y0, pixel);

		if (x0 = x1) and (y0 = y1) then
			break;

		errorDouble := errorValue * 2;

		if errorDouble >= deltaY then begin
			errorValue := errorValue + deltaY;
			x0 := x0 + stepX;
		end;

		if errorDouble <= deltaX then begin
			errorValue := errorValue + deltaX;
			y0 := y0 + stepY;
		end;
	end;
end;

procedure PoglDrawFaces(
	const model: TObjModel;
	const screenVerteces: TScreenVertexArray);
var
	i, j, next: integer;
	vertexIndex, nextVertexIndex: integer;
begin
	for i := 0 to high(model.faces) do begin
		if length(model.faces[i]) < 2 then
			continue;

		for j := 0 to high(model.faces[i]) do begin
			next := j + 1;

			if next > high(model.faces[i]) then
				next := 0;

			vertexIndex := model.faces[i][j];
			nextVertexIndex := model.faces[i][next];

			PoglDrawLine(
				screenVerteces[vertexIndex].x,
				screenVerteces[vertexIndex].y,
				screenVerteces[nextVertexIndex].x,
				screenVerteces[nextVertexIndex].y,
				colorWhite
			);
		end;
	end;
end;

procedure PoglDrawObjModel(const model: TObjModel);
var
	i: integer;
	scale: single;
begin
	if length(model.rotatedVerteces) = 0 then
		exit;

	if length(screenVerteces) <> length(model.rotatedVerteces) then
		setlength(screenVerteces, length(model.rotatedVerteces));

	scale := MinSingle(
		globArgs.width / (model.vmax.x - model.vmin.x),
		globArgs.height / (model.vmax.y - model.vmin.y)
	);

	for i := 0 to high(model.rotatedVerteces) do begin
		screenVerteces[i].x := round(
			(model.rotatedVerteces[i].x - model.center.x) * scale + moveX
		);

		screenVerteces[i].y := round(
			(model.rotatedVerteces[i].y - model.center.y) * scale + moveY
		);
	end;

	PoglDrawFaces(model, screenVerteces);
end;

end.
