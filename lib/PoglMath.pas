unit PoglMath;

interface

uses PoglModel;

const
	PI = 3.14;
	FULL_ANGLE = 360.0;
	SEMI_ANGLE = 180.0;
	RAD_TO_DEG = 180.0 / pi;
	DEG_TO_RAD = pi / 180.0;

procedure RotateModel(var model: TObjModel; angleX, angleY, angleZ: single);
procedure RotateVertex(
	const vertex, center: TVertex;
	const vsin, vcos: TVertex;
	var result: TVertex);

function MinSingle(x, y: single): single;

implementation

function MinSingle(x, y: single): single;
begin
	if x < y then
		MinSingle := x
	else
		MinSingle := y;
end;

procedure RotateModel(var model: TObjModel; angleX, angleY, angleZ: single);
var
	i: integer;
	vsin, vcos: TVertex;
begin
	with model do begin
		InitVertex(angle, angle.x + angleX, angle.y + angleY, angle.z + angleZ);

		InitVertex(vsin,
			sin(angle.x * DEG_TO_RAD),
			sin(angle.y * DEG_TO_RAD),
			sin(angle.z * DEG_TO_RAD)
		);
		InitVertex(vcos,
			cos(angle.x * DEG_TO_RAD),
			cos(angle.y * DEG_TO_RAD),
			cos(angle.z * DEG_TO_RAD)
		);
		
		for i := 0 to high(verteces) do begin
			RotateVertex(
				verteces[i],
				center,
				vsin, vcos,
				rotatedVerteces[i]
			);
		end;
	end;
end;

procedure RotateVertex(
	const vertex, center: TVertex;
	const vsin, vcos: TVertex;
	var result: TVertex);
var
	x, y, z, newX, newY, newZ: single;
begin
	x := vertex.x - center.x;
	y := vertex.y - center.y;
	z := vertex.z - center.z;

	newY := y * vcos.x - z * vsin.x;
	newZ := y * vsin.x + z * vcos.x;
	y := newY;
	z := newZ;

	newX := x * vcos.y + z * vsin.y;
	newZ := -x * vsin.y + z * vcos.y;
	x := newX;
	z := newZ;

	newX := x * vcos.z - y * vsin.z;
	newY := x * vsin.z + y * vcos.z;
	x := newX;
	y := newY;

	result.x := x + center.x;
	result.y := y + center.y;
	result.z := z + center.z;
end;


end.

