program point;

uses PoglLib, PoglArgs;

procedure ReadArgs(var args: TPoglArgs);
begin
	if ParamCount < 1 then begin
		writeln('File name expected as the first argument to program');
		halt(1);
	end;
	args.fileName := ParamStr(1);

	if ParamCount = 3 then begin
		halt(1);
	end;
	
	if ParamCount < 3 then begin
		args.width := 600;
		args.height := 400;
	end;

end;

var
	args: TPoglArgs;
begin
	ReadArgs(args);

	PoglPrepare(args);
	PoglInitWindow;

	PoglMainloop;
	
	PoglCleanUp;
end.
