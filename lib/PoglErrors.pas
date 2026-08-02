unit PoglErrors;

interface

uses sdl2;

const
	ErrorBoxTitle = 'Error Message';

procedure PoglErrorHandler;

implementation

procedure PoglErrorHandler;
var
	statusCode: integer;
begin
	statusCode := sdl_ShowSimpleMessageBox(
		SDL_MESSAGEBOX_ERROR,
		ErrorBoxTitle,
		sdl_GetError,
		nil
	);
	if statusCode <> 0 then begin
		PoglErrorHandler;
		Exit
	end
end;

end.

