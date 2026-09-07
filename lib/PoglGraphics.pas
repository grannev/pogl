unit PoglGraphics;

interface

uses sdl2, PoglArgs, PoglModel, PoglColors, PoglWindowSize, PoglMath;

type
	TFrameBuffer = array 
	[1..poglMainWindowSize] of TColor;
	TZBuffer = array
	[1..poglMainWindowSize] of single;

const
	lineDepthBias = 0.0001;
	screenMinX = -(poglMainWindowWidth div 2);
	screenMaxX = poglMainWindowWidth - poglMainWindowWidth div 2 - 1;
	screenMinY = poglMainWindowHeight div 2 - poglMainWindowHeight + 1;
	screenMaxY = poglMainWindowHeight div 2;

var
	frameBuffer: TFrameBuffer;
	zBuffer: TZBuffer;
	globArgs: TPoglArgs;
	screenVerteces: TScreenVertexArray;
	moveX, moveY: single;

procedure PoglPrepareGraphics(const args: TPoglArgs);
procedure PoglClearBuffers(color: TColor);
procedure PoglPutPixel(
	x, y: longint;
	z: single;
	color: TColor); inline;
procedure PoglDrawObjModel(
	const model: TObjModel;
	updateScreenVerteces: boolean);

implementation

procedure PoglClearBuffers(color: TColor);
var
	i: longint;
begin
	for i := 1 to poglMainWindowSize do begin
		frameBuffer[i] := color;
		zBuffer[i] := -1.0E30;
	end;
end;

procedure PoglPrepareGraphics(const args: TPoglArgs);
begin
	globArgs := args;
	moveX := 0;
	moveY := 0;
end;

procedure PoglPutPixel(
	x, y: longint;
	z: single;
	color: TColor); inline;
var
	index: longint;
begin
	x := poglMainWindowWidth div 2 + x;
	y := poglMainWindowHeight div 2 - y;

	if  (x < 0) or (x >= poglMainWindowWidth)  or
		(y < 0) or (y >= poglMainWindowHeight) then
		exit;

	index := longint(y) * poglMainWindowWidth + x + 1;

	if z < zBuffer[index] then
		exit;

	zBuffer[index] := z;
	frameBuffer[index] := color;
end;

function PoglTriangleVisible(const v1, v2, v3: TScreenVertex): boolean;
{ back face culling optimization }
var
	area: int64;
	minX, maxX, minY, maxY: longint;
begin
	area :=
		(int64(v2.x) - v1.x) * (int64(v3.y) - v1.y) -
		(int64(v2.y) - v1.y) * (int64(v3.x) - v1.x);
	{ (area = 0) => degenerate triangle }
	{ (area < 0) => back face of triangle }
	{ (area > 0) => front face of triangle - our target :) }

	if area <= 0 then begin
		PoglTriangleVisible := false;
		exit;
	end;

	{ checking if triangle is out of window borders }

	minX := v1.x;
	maxX := v1.x;
	minY := v1.y;
	maxY := v1.y;

	if v2.x < minX then
		minX := v2.x;
	if v3.x < minX then
		minX := v3.x;
	if v2.x > maxX then
		maxX := v2.x;
	if v3.x > maxX then
		maxX := v3.x;

	if v2.y < minY then
		minY := v2.y;
	if v3.y < minY then
		minY := v3.y;
	if v2.y > maxY then
		maxY := v2.y;
	if v3.y > maxY then
		maxY := v3.y;

	PoglTriangleVisible :=
		(maxX >= screenMinX) and (minX <= screenMaxX) and
		(maxY >= screenMinY) and (minY <= screenMaxY);
end;

procedure PoglDrawLine(
	const v0, v1: TScreenVertex;
	color: TColor);
var
	deltaX, deltaY: longint;
	stepX, stepY: longint;
	errorValue, errorDouble: longint;
	depthSteps: longint;
	x0, y0, x1, y1: longint;
	z, zStep: single;
begin
	x0 := v0.x;
	y0 := v0.y;
	x1 := v1.x;
	y1 := v1.y;
	z := v0.z;

	deltaX := abs(x1 - x0);
	deltaY := abs(y1 - y0);

	if deltaX > deltaY then
		depthSteps := deltaX
	else
		depthSteps := deltaY;

	if depthSteps = 0 then
		zStep := 0
	else
		zStep := (v1.z - v0.z) / depthSteps;

	deltaY := -deltaY;

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
		PoglPutPixel(x0, y0, z + lineDepthBias, color);

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

		z := z + zStep;
	end;
end;

procedure PoglDrawSpan(
	y: longint;
	firstX, firstZ, secondX, secondZ: single;
	color: TColor);
var
	temp: single;
	z, zStep: single;
	x, xStart, xEnd: longint;
	screenX, screenY: longint;
	index: longint;
begin
	if (y < screenMinY) or (y > screenMaxY) then
		exit; { TODO: check if this necessary }

	if firstX > secondX then begin
		temp := firstX;
		firstX := secondX;
		secondX := temp;

		temp := firstZ;
		firstZ := secondZ;
		secondZ := temp;
	end;

	xStart := round(firstX);
	xEnd := round(secondX);

	if (xEnd < screenMinX) or (xStart > screenMaxX) then
		exit;

	if xStart = xEnd then begin
		zStep := 0;
		z := (firstZ + secondZ) / 2;
	end else begin
		zStep := (secondZ - firstZ) / (xEnd - xStart);
		z := firstZ;
	end;

	if xStart < screenMinX then begin
		z := z + (screenMinX - xStart) * zStep;
		xStart := screenMinX;
	end;

	if xEnd > screenMaxX then
		xEnd := screenMaxX;

	screenX := poglMainWindowWidth div 2 + xStart;
	screenY := poglMainWindowHeight div 2 - y;
	index := longint(screenY) * poglMainWindowWidth + screenX + 1;

	for x := xStart to xEnd do begin
		if z >= zBuffer[index] then begin
			zBuffer[index] := z;
			frameBuffer[index] := color;
		end;

		index := index + 1;
		z := z + zStep;
	end;
end;

procedure PoglDrawTrianglePart(
	yStart, yEnd: longint;
	firstX, firstZ, firstXStep, firstZStep: single;
	secondX, secondZ, secondXStep, secondZStep: single;
	color: TColor);
var
	y, skippedRows: longint;
begin
	if (yStart > yEnd) or (yEnd < screenMinY) or
	(yStart > screenMaxY) then
		exit;

	if yStart < screenMinY then begin
		skippedRows := screenMinY - yStart;
		firstX := firstX + firstXStep * skippedRows;
		firstZ := firstZ + firstZStep * skippedRows;
		secondX := secondX + secondXStep * skippedRows;
		secondZ := secondZ + secondZStep * skippedRows;
		yStart := screenMinY;
	end;

	if yEnd > screenMaxY then
		yEnd := screenMaxY;

	for y := yStart to yEnd do begin
		PoglDrawSpan(y, firstX, firstZ, secondX, secondZ, color);

		firstX := firstX + firstXStep;
		firstZ := firstZ + firstZStep;
		secondX := secondX + secondXStep;
		secondZ := secondZ + secondZStep;
	end;
end;

procedure PoglDrawTriangle(v1, v2, v3: TScreenVertex; const color: TColor);
{ Using scanline rendering algorithm }
var
	totalHeight, segmentHeight: longint;
	firstPartEnd: longint;
	longX, longZ, longXStep, longZStep: single;
	shortXStep, shortZStep: single;
begin
	if not PoglTriangleVisible(v1, v2, v3) then
		exit;

	if v1.y > v2.y then
		SwapScreenVertex(v1, v2);
	if v1.y > v3.y then
		SwapScreenVertex(v1, v3);
	if v2.y > v3.y then
		SwapScreenVertex(v2, v3);

	totalHeight := v3.y - v1.y;
	if totalHeight = 0 then
		exit;

	{ Making interpolation of x by y for the longest edge }
	longXStep := (v3.x - v1.x) / totalHeight;
	longZStep := (v3.z - v1.z) / totalHeight;

	segmentHeight := v2.y - v1.y;
	if segmentHeight > 0 then begin
		{ Making interpolation of x by y for one of shortened edge }
		shortXStep := (v2.x - v1.x) / segmentHeight;
		shortZStep := (v2.z - v1.z) / segmentHeight;
		firstPartEnd := v2.y - 1;

		if v2.y = v3.y then
			firstPartEnd := v2.y;

		PoglDrawTrianglePart(
			v1.y,
			firstPartEnd,
			v1.x, v1.z, longXStep, longZStep,
			v1.x, v1.z, shortXStep, shortZStep,
			color
		);
	end;

	segmentHeight := v3.y - v2.y;
	if segmentHeight > 0 then begin
		{ Making interpolation of x by y for one of shortened edge }
		shortXStep := (v3.x - v2.x) / segmentHeight;
		shortZStep := (v3.z - v2.z) / segmentHeight;
		
		longX := v1.x + longXStep * (v2.y - v1.y);
		longZ := v1.z + longZStep * (v2.y - v1.y);

		PoglDrawTrianglePart(
			v2.y,
			v3.y,
			longX, longZ, longXStep, longZStep,
			v2.x, v2.z, shortXStep, shortZStep,
			color
		);
	end;
end;

function PoglFaceVisible(
	const face: TFace;
	const screenVerteces: TScreenVertexArray): boolean;
{ A polygon is visible when at least one triangle of its fan is }
var
	i: longint;
begin
	PoglFaceVisible := true;

	for i := 2 to high(face) do
		if PoglTriangleVisible(
			screenVerteces[face[0].vertexIndex],
			screenVerteces[face[i - 1].vertexIndex],
			screenVerteces[face[i].vertexIndex]
		) then
			exit;

	PoglFaceVisible := false;
end;

procedure PoglFillFace(
	const face: TFace;
	const screenVerteces: TScreenVertexArray;
	const color: TColor);
{ Polygons with more than three verteces are split into a triangle fan }
var
	i: longint;
begin
	for i := 2 to high(face) do
		PoglDrawTriangle(
			screenVerteces[face[0].vertexIndex],
			screenVerteces[face[i - 1].vertexIndex],
			screenVerteces[face[i].vertexIndex],
			color
		);
end;

procedure PoglDrawFaces(
	const model: TObjModel;
	const screenVerteces: TScreenVertexArray);
var
	i, j, next: longint;
	vertexIndex, nextVertexIndex: longint;
begin
	with model do begin
		for i := 0 to high(faces) do begin
			if length(faces[i]) < 3 then
				continue;

			PoglFillFace(faces[i], screenVerteces, colorGreen);
		end;

		for i := 0 to high(faces) do begin
			if length(faces[i]) < 3 then
				continue;

			if not PoglFaceVisible(faces[i], screenVerteces) then
				continue;

			for j := 0 to high(faces[i]) do begin
				next := j + 1;

				if next > high(faces[i]) then
					next := 0;

				vertexIndex := faces[i][j].vertexIndex;
				nextVertexIndex := faces[i][next].vertexIndex;

				PoglDrawLine(
					screenVerteces[vertexIndex],
					screenVerteces[nextVertexIndex],
					colorLime
				);
			end;
		end;
	end;
end;

procedure PoglDrawObjModel(
	const model: TObjModel;
	updateScreenVerteces: boolean);
var
	i: longint;
	scale: single;
begin
	if length(model.rotatedVerteces) = 0 then
		exit;

	if length(screenVerteces) <> length(model.rotatedVerteces) then begin
		setlength(screenVerteces, length(model.rotatedVerteces));
		updateScreenVerteces := true;
	end;

	if updateScreenVerteces then begin
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

			screenVerteces[i].z :=
				model.rotatedVerteces[i].z - model.center.z;
		end;
	end;

	PoglDrawFaces(model, screenVerteces);
end;

end.
