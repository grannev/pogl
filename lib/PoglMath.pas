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
	angleX, angleY, angleZ: single;
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
begin
	with model do begin
		InitVertex(angle, angle.x + angleX, angle.y + angleY, angle.z + angleZ);
		for i := 0 to high(verteces) do begin
			RotateVertex(
				verteces[i],
				center,
				angle.x, angle.y, angle.z,
				rotatedVerteces[i]
			);
		end;
	end;
end;

procedure RotateVertex(
	const vertex, center: TVertex;
	angleX, angleY, angleZ: single;
	var result: TVertex);
var
	x, y, z, newX, newY, newZ: single;
	sinX, cosX, sinY, cosY, sinZ, cosZ: single;
begin
	sinX := sin(angleX * DEG_TO_RAD);
	cosX := cos(angleX * DEG_TO_RAD);
	sinY := sin(angleY * DEG_TO_RAD);
	cosY := cos(angleY * DEG_TO_RAD);
	sinZ := sin(angleZ * DEG_TO_RAD);
	cosZ := cos(angleZ * DEG_TO_RAD);

	x := vertex.x - center.x;
	y := vertex.y - center.y;
	z := vertex.z - center.z;

	{ Вращение вокруг X }

	newY := y * cosX - z * sinX;
	newZ := y * sinX + z * cosX;
	y := newY;
	z := newZ;

	{ Вращение вокруг Y }

	newX := x * cosY + z * sinY;
	newZ := -x * sinY + z * cosY;
	x := newX;
	z := newZ;

	{ Вращение вокруг Z }

	newX := x * cosZ - y * sinZ;
	newY := x * sinZ + y * cosZ;
	x := newX;
	y := newY;

	result.x := x + center.x;
	result.y := y + center.y;
	result.z := z + center.z;
end;


end.

