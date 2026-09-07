unit PoglParser;

interface

uses PoglModel, sysutils, strutils;

procedure ParseObjFile(fileName: string; var model: TObjModel);

implementation

const
	spaceChar = ' ';
	tabChar = #9;
	wordSeparators = [spaceChar, tabChar];

procedure ParseVertex(line: string; var vertex: TVertex);
var
	unused: char;
begin
	readstr(line, unused, vertex.x, vertex.y, vertex.z);
end;

procedure ParseTextureVertex(line: string; var vertex: TVertex);
var
	wordsCount: integer;
begin
	wordsCount := wordcount(line, wordSeparators);
	vertex.x := 0;
	vertex.y := 0;
	vertex.z := 0;

	if wordsCount >= 2 then
		vertex.x := strtofloat(extractword(2, line, wordSeparators));
	if wordsCount >= 3 then
		vertex.y := strtofloat(extractword(3, line, wordSeparators));
	if wordsCount >= 4 then
		vertex.z := strtofloat(extractword(4, line, wordSeparators));
end;

procedure ParseNormal(line: string; var normal: TVertex);
begin
	normal.x := strtofloat(extractword(2, line, wordSeparators));
	normal.y := strtofloat(extractword(3, line, wordSeparators));
	normal.z := strtofloat(extractword(4, line, wordSeparators));
end;

function ParseIndex(value: string; elementsCount: integer): integer;
var
	index: integer;
begin
	if value = '' then begin
		ParseIndex := -1;
		exit;
	end;

	index := strtoint(value);
	if index > 0 then
		ParseIndex := index - 1
	else if index < 0 then
		ParseIndex := elementsCount + index
	else
		ParseIndex := -1;
end;

procedure ParseFaceVertex(
	element: string;
	vertecesCount, textureVertecesCount, normalsCount: integer;
	var vertex: TFaceVertex);
var
	firstSlash, secondSlash: integer;
	remaining: string;
begin
	vertex.vertexIndex := -1;
	vertex.textureIndex := -1;
	vertex.normalIndex := -1;

	firstSlash := pos('/', element);
	if firstSlash = 0 then begin
		vertex.vertexIndex := ParseIndex(element, vertecesCount);
		exit;
	end;

	vertex.vertexIndex := ParseIndex(
		copy(element, 1, firstSlash - 1),
		vertecesCount
	);
	remaining := copy(element, firstSlash + 1, length(element));
	secondSlash := pos('/', remaining);

	if secondSlash = 0 then begin
		vertex.textureIndex := ParseIndex(
			remaining,
			textureVertecesCount
		);
		exit;
	end;

	vertex.textureIndex := ParseIndex(
		copy(remaining, 1, secondSlash - 1),
		textureVertecesCount
	);
	vertex.normalIndex := ParseIndex(
		copy(remaining, secondSlash + 1, length(remaining)),
		normalsCount
	);
end;

procedure ParseFace(
	line: string;
	vertecesCount, textureVertecesCount, normalsCount: integer;
	var face: TFace);
var
	i, wordsCount: integer;
	element: string;
begin
	wordsCount := wordcount(line, wordSeparators);
	setlength(face, wordsCount - 1);

	for i := 2 to wordsCount do begin
		element := extractword(i, line, wordSeparators);
		ParseFaceVertex(
			element,
			vertecesCount,
			textureVertecesCount,
			normalsCount,
			face[i - 2]
		);
	end;
end;

procedure CountObjElements(
	fileName: string;
	var vertecesCount, textureVertecesCount: integer;
	var normalsCount, facesCount: integer);
var
	objFile: textfile;
	line: string;
begin
	vertecesCount := 0;
	textureVertecesCount := 0;
	normalsCount := 0;
	facesCount := 0;

	assign(objFile, fileName);
	reset(objFile);

	while not eof(objFile) do begin
		readln(objFile, line);
		line := Trim(line);

		if pos('v ', line) = 1 then
			vertecesCount := vertecesCount + 1
		else if pos('vt ', line) = 1 then
			textureVertecesCount := textureVertecesCount + 1
		else if pos('vn ', line) = 1 then
			normalsCount := normalsCount + 1
		else if pos('f ', line) = 1 then
			facesCount := facesCount + 1;
	end;

	close(objFile);
end;

procedure ParseObjFile(fileName: string; var model: TObjModel);
var
	objFile: textfile;
	line: string;
	vertecesCount, textureVertecesCount: integer;
	normalsCount, facesCount: integer;
	vertexIndex, textureVertexIndex: integer;
	normalIndex, faceIndex: integer;
begin
	CountObjElements(
		fileName,
		vertecesCount,
		textureVertecesCount,
		normalsCount,
		facesCount
	);

	setlength(model.verteces, vertecesCount);
	setlength(model.textureVerteces, textureVertecesCount);
	setlength(model.normals, normalsCount);
	setlength(model.faces, facesCount);

	vertexIndex := 0;
	textureVertexIndex := 0;
	normalIndex := 0;
	faceIndex := 0;

	assign(objFile, fileName);
	reset(objFile);

	while not eof(objFile) do begin
		readln(objFile, line);
		line := Trim(line);

		if pos('v ', line) = 1 then begin
			ParseVertex(line, model.verteces[vertexIndex]);
			vertexIndex := vertexIndex + 1;
		end else if pos('vt ', line) = 1 then begin
			ParseTextureVertex(
				line,
				model.textureVerteces[textureVertexIndex]
			);
			textureVertexIndex := textureVertexIndex + 1;
		end else if pos('vn ', line) = 1 then begin
			ParseNormal(line, model.normals[normalIndex]);
			normalIndex := normalIndex + 1;
		end else if pos('f ', line) = 1 then begin
			ParseFace(
				line,
				vertexIndex,
				textureVertexIndex,
				normalIndex,
				model.faces[faceIndex]
			);
			faceIndex := faceIndex + 1;
		end;
	end;

	close(objFile);
end;

end.
