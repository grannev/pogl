unit PoglLib;

interface

uses
	sdl2,
	PoglErrors,
	PoglColors,
	PoglWindowSize,
	PoglArgs,
	PoglMath,
	PoglParser,
	PoglModel;

const
	programName = 'Pogl';

type
	TPixel = longword;
	TFrameBuffer = array 
	[1..poglMainWindowSize] of TPixel;

var
	statusCode: integer;
	poglMainWindow: psdl_Window;
	sdlRenderer: psdl_Renderer;
	screenTexture: psdl_Texture;
	frameBuffer: TFrameBuffer;
	globArgs: TPoglArgs;
	model: TObjModel;
	i: integer;

procedure PoglInitObjModel(args: TPoglArgs);
procedure PoglInitWindow;
procedure PoglMainloop;
procedure PoglCleanUp;

implementation

procedure PoglClearScreen(pixel: TPixel);
var
	i: longint;
begin
	for i := 1 to poglMainWindowSize do
		frameBuffer[i] := pixel;
end;

procedure PoglPutPixel(x, y: integer; pixel: TPixel);
begin
	if (x < 0) or (x >= poglMainWindowWidth) or
	   (y < 0) or (y >= poglMainWindowHeight) then
		Exit;
	frameBuffer[y * poglMainWindowWidth + x] := pixel;
end;

procedure PoglInitObjModel(args: TPoglArgs);
begin
	globArgs := args;
	ParseObjFile(globArgs.fileName, model);
	WriteModel(model);
end;

procedure PoglInitWindow;
begin
	poglMainWindow := nil;
	sdlRenderer := nil;
	screenTexture := nil;

	statusCode := SDL_Init(SDL_INIT_VIDEO);
	if statusCode < 0 then
		PoglCleanUp;

	poglMainWindow := SDL_CreateWindow(
		programName,
		SDL_WINDOWPOS_UNDEFINED,
		SDL_WINDOWPOS_UNDEFINED,
		poglMainWindowWidth,
		poglMainWindowHeight,
		SDL_WINDOW_SHOWN
	);
	if poglMainWindow = nil then
		PoglCleanUp;

	sdlRenderer := SDL_CreateRenderer(poglMainWindow, -1, 0);
	if sdlRenderer = nil then
		PoglCleanUp;

	screenTexture := SDL_CreateTexture(
		sdlRenderer,
		SDL_PIXELFORMAT_ARGB8888,
		SDL_TEXTUREACCESS_STREAMING,
		poglMainWindowWidth,
		poglMainWindowHeight
	);
	if screenTexture = nil then
		PoglCleanUp;
end;


procedure PoglMainloop;
var
	event: TSDL_Event;
	isRunning: boolean;
begin
	isRunning := true;

	while isRunning do begin
		while sdl_PollEvent(@event) <> 0 do begin
			case event.type_ of
			SDL_QUITEV:
				isRunning := false;

			SDL_KEYDOWN:
				case event.key.keysym.sym of
				SDLK_ESCAPE:
					isRunning := false;

					SDLK_LEFT:
						writeln('Left');

					SDLK_RIGHT:
						writeln('Right');
				end;
			end;
		end;

		if not isRunning then
			break;

		PoglClearScreen(colorBlack);

		{ Изменение и отрисовка модели }

		sdl_UpdateTexture(
			screenTexture,
			nil,
			@frameBuffer[1],
			poglMainWindowWidth * SizeOf(TPixel)
		);
		sdl_RenderClear(sdlRenderer);
		sdl_RenderCopy(sdlRenderer, screenTexture, nil, nil);
		sdl_RenderPresent(sdlRenderer);

		sdl_Delay(16);
	end;
end;



procedure PoglCleanAfterError;
begin
	PoglErrorHandler;

	if screenTexture <> nil then
		sdl_DestroyTexture(screenTexture);

	if sdlRenderer <> nil then
		sdl_DestroyRenderer(sdlRenderer);

	if poglMainWindow <> nil then
		sdl_DestroyWindow(poglMainWindow);

	sdl_Quit;

	halt(1);
end;

procedure PoglCleanUp;
begin
	if screenTexture <> nil then
		sdl_DestroyTexture(screenTexture);

	if sdlRenderer <> nil then
		sdl_DestroyRenderer(sdlRenderer);

	if poglMainWindow <> nil then
		sdl_DestroyWindow(poglMainWindow);

	sdl_Quit;
end;

end.

