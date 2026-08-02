program point;

uses PoglLib, PoglArgs;

procedure ReadArgs(var args: TPoglArgs);
begin
	if ParamCount < 1 then begin
		writeln('File name expected as the first argument to program');
		halt(1);
	end;
	args.fileName := ParamStr(1);
end;

var
	args: TPoglArgs;
begin
	ReadArgs(args);
	PoglInitObjModel(args);
	PoglInitWindow;

	PoglMainloop;
	
	PoglCleanUp;
end.
