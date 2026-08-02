unit PoglParser;

interface

uses PoglModel, sysutils, strutils;

procedure ParseObjFile(fileName: string; var model: TObjModel);

implementation

procedure ParseVertex(line: string; var model: TObjModel);
var
	unused: char;
	vertex: TVertex;
begin
	readstr(line, unused, vertex.x, vertex.y, vertex.z);
	AddVertex(model.verteces, vertex);
end;

procedure ParseFace(line: string; var model: TObjModel);
var
	i, wordsCount, slashPos, vertexIndex: integer;
	element: string;
	face: TFace;
begin
	wordsCount := wordcount(line, [' ', #9]);
	setlength(face, wordsCount - 1);

	for i := 2 to wordsCount do begin
		element := extractword(i, line, [' ', #9]);
		slashPos := pos('/', element);
		if slashPos = 0 then
			vertexIndex := strtoint(element)
		else
			vertexIndex := strtoint(copy(element, 1, slashPos - 1));

		if vertexIndex > 0 then
			face[i - 2] := vertexIndex - 1
		else
			face[i - 2] := length(model.verteces) + vertexIndex;
	end;

	setlength(model.faces, length(model.faces) + 1);
	model.faces[high(model.faces)] := face;
end;

procedure ParseObjFile(fileName: string; var model: TObjModel);
var
	objFile: textfile;
	line: string;
begin
	assign(objFile, fileName);
	reset(objFile);

	while not eof(objFile) do begin
		readln(objFile, line);
		line := Trim(line);

		if pos('v ', line) = 1 then
			ParseVertex(line, model);
		if pos('f ', line) = 1 then
			ParseFace(line, model);

	end;

	close(objFile);
end;

end.
