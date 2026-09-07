unit PoglModel;

interface

type
	TScreenVertex = record
		x, y: integer;
		z: single;
	end;

	TScreenVertexArray = array of TScreenVertex;

	TVertex = record
		x, y, z: single;
	end;

	TFaceVertex = record
		vertexIndex: integer;
		textureIndex: integer;
		normalIndex: integer;
	end;

	TFace = array of TFaceVertex;

	TVertexArray = array of TVertex;
	TFaceArray = array of TFace;

	TObjModel = record
		vmax, vmin: TVertex;
		angle: TVertex;
		center: TVertex;

		verteces: TVertexArray;
		textureVerteces: TVertexArray;
		normals: TVertexArray;
		rotatedVerteces: TVertexArray;

		faces: TFaceArray;
	end;

procedure FindMaxMinVerteces(var model: TObjModel);
procedure WriteModel(const model: TObjModel);

procedure SwapScreenVertex(var a, b: TScreenVertex);

procedure InitVertex(var vertex: TVertex; x, y, z: single);
procedure WriteVertex(const vertex: TVertex);

implementation

procedure SwapScreenVertex(var a, b: TScreenVertex);
var
	temp: TScreenVertex;
begin
	temp := a;
	a := b;
	b := temp;
end;

procedure WriteVertex(const vertex: TVertex);
begin
	with vertex do
		writeln('v(', x, ' ', y, ' ', z, ')');
end;

procedure WriteFace(const face: TFace);
var
	i: integer;
begin
	write('f(');
	for i := 0 to high(face) do begin
		if i > 0 then
			write(' ');
		write(
			face[i].vertexIndex, '/',
			face[i].textureIndex, '/',
			face[i].normalIndex
		);
	end;
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

end.
