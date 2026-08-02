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
	PoglModel,
	PoglGraphics;

type
	TKeyboardState = array [0..511] of byte;
	PKeyboardState = ^TKeyboardState;

const
	programName = 'Pogl';

var
	statusCode: integer;
	poglMainWindow: psdl_Window;
	sdlRenderer: psdl_Renderer;
	screenTexture: psdl_Texture;
	model: TObjModel;
	isRunning: boolean;

procedure PoglPrepare(const args: TPoglArgs);
procedure PoglInitWindow;
procedure PoglMainloop;
procedure PoglCleanUp;

implementation

procedure PoglPrepare(const args: TPoglArgs);
var
	i: integer;
begin
	PoglPrepareGraphics(args);
	ParseObjFile(globArgs.fileName, model);
	FindMaxMinVerteces(model);
	with model do begin
		InitVertex(center,
			(vmin.x + vmax.x) / 2,
			(vmin.y + vmax.y) / 2,
			(vmin.z + vmax.z) / 2);
		InitVertex(angle, 0.0, 0.0, 0.0);
	end;

	setlength(model.rotatedVerteces, length(model.verteces));
	for i := 0 to high(model.verteces) do
		model.rotatedVerteces[i] := model.verteces[i];
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

procedure PoglHandleKeyboard(deltaTime: single);
const
	rotationSpeed = 90.0; { градусов в секунду }
var
	keyboard: PKeyboardState;
	rotation: single;
begin
	keyboard := PKeyboardState(sdl_GetKeyboardState(nil));
	rotation := rotationSpeed * deltaTime;

	if keyboard^[SDL_SCANCODE_LEFT] <> 0 then
		RotateModel(model, 0, -rotation, 0);

	if keyboard^[SDL_SCANCODE_RIGHT] <> 0 then
		RotateModel(model, 0, rotation, 0);

	if keyboard^[SDL_SCANCODE_UP] <> 0 then
		RotateModel(model, rotation, 0, 0);

	if keyboard^[SDL_SCANCODE_DOWN] <> 0 then
		RotateModel(model, -rotation, 0, 0);

	if keyboard^[SDL_SCANCODE_PAGEUP] <> 0 then
		RotateModel(model, 0, 0, rotation);

	if keyboard^[SDL_SCANCODE_PAGEDOWN] <> 0 then
		RotateModel(model, 0, 0, -rotation);
end;

procedure PoglHandleEvents;
var
	event: TSDL_Event;
begin
	while sdl_PollEvent(@event) <> 0 do begin
		case event.type_ of
		SDL_QUITEV:
			isRunning := false;

		SDL_KEYDOWN:
			if event.key.keysym.sym = SDLK_ESCAPE then
				isRunning := false;
		end;
	end;
end;

procedure PoglPresentScreen;
begin
	sdl_UpdateTexture(
		screenTexture,
		nil,
		@frameBuffer[1],
		poglMainWindowWidth * SizeOf(TPixel)
	);
	sdl_RenderClear(sdlRenderer);
	sdl_RenderCopy(sdlRenderer, screenTexture, nil, nil);
	sdl_RenderPresent(sdlRenderer);
end;

procedure PoglMainloop;
var
	previousTicks, currentTicks: longword;
	deltaTime: single;
begin
	isRunning := true;
	previousTicks := sdl_GetTicks;

	while isRunning do begin
		currentTicks := sdl_GetTicks;
		deltaTime := (currentTicks - previousTicks) / 1000.0;
		previousTicks := currentTicks;

		if deltaTime > 0.05 then
			deltaTime := 0.05;

		PoglHandleEvents;

		if not isRunning then
			break;

		PoglHandleKeyboard(deltaTime);

		PoglClearScreen(colorBlack);
		PoglDrawObjModel(model);

		{ Изменение и отрисовка модели }
		PoglPresentScreen();
		sdl_Delay(5);
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
