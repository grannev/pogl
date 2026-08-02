unit PoglModel;

interface

type
	TScreenVertex = record
		x, y: integer;
	end;

	TScreenVertexArray = array of TScreenVertex;

	TVertex = record
		x, y, z: single;
	end;
	TFace = array of integer;

	TVertexArray = array of TVertex;
	TFaceArray = array of TFace;

	TObjModel = record
		vmax, vmin: TVertex;
		angle: TVertex;
		center: TVertex;

		verteces: TVertexArray;
		rotatedVerteces: TVertexArray;

		faces: TFaceArray;
	end;

procedure FindMaxMinVerteces(var model: TObjModel);
procedure InitVertex(var vertex: TVertex; x, y, z: single);
procedure AddVertex(var verteces: TVertexArray; const vertex: TVertex);
procedure WriteVertex(const vertex: TVertex);
procedure WriteModel(const model: TObjModel);

implementation

procedure WriteVertex(const vertex: TVertex);
begin
	with vertex do
		writeln('v(', x, ' ', y, ' ', z, ')');
end;

procedure WriteFace(const face: TFace);
var
	i: integer;
begin
	write('f(', face[0]);
	for i := 1 to high(face) do
		write(' ', face[i]);
	writeln(')');
end;

procedure FindMaxMinVerteces(var model: TObjModel);
var
	i: integer;
begin
	with model do begin
		InitVertex(vmax, verteces[0].x, verteces[0].y, verteces[0].z);
		InitVertex(vmin, verteces[0].x, verteces[0].y, verteces[0].z);

		for i := 0 to high(verteces) do begin
			if vmax.x < verteces[i].x then
				vmax.x := verteces[i].x;
			if vmin.x > verteces[i].x then
				vmin.x := verteces[i].x;
			
			if vmax.y < verteces[i].y then
				vmax.y := verteces[i].y;
			if vmin.y > verteces[i].y then
				vmin.y := verteces[i].y;
			
			if vmax.z < verteces[i].z then
				vmax.z := verteces[i].z;
			if vmin.z > verteces[i].z then
				vmin.z := verteces[i].z;
		end;
	end;
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

