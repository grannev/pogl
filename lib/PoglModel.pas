unit PoglModel;

interface

uses PoglMath;

type
	TVertex = record
		x, y, z: single;
	end;
	TFace = array of integer;

	TVertexArray = array of TVertex;
	TFaceArray = array of TFace;

	TObjModel = record
		verteces: TVertexArray;
		faces: TFaceArray;
	end;

procedure InitVertex(var vertex: TVertex; x, y, z: single);
procedure AddVertex(var verteces: TVertexArray; const vertex: TVertex);
procedure WriteVertex(const vertex: TVertex);
procedure WriteModel(const model: TObjModel);

implementation

procedure WriteVertex(const vertex: TVertex);
begin
	writeln('v(', vertex.x, ' ', vertex.y, ' ', vertex.z, ')');
end;

procedure WriteFace(const face: TFace);
var
	i: integer;
begin
	write('f(', face[0]);
	for i := 1 to length(face) do
		write(' ', face[i]);
	writeln(')');
end;

procedure WriteModel(const model: TObjModel);
var
	i: integer;
begin
	for i := 0 to high(model.verteces) do
		WriteVertex(model.verteces[i]);
	for i := 0 to high(model.faces) do
		WriteFace(model.faces[i]);
end;

procedure InitVertex(var vertex: TVertex; x, y, z: single);
begin
	vertex.x := x;
	vertex.y := y;
	vertex.z := z;
end;

procedure AddVertex(var verteces: TVertexArray; const vertex: TVertex);
begin
	setlength(verteces, length(verteces) + 1);
	verteces[high(verteces)] := vertex;
end;


end.

