program point;

{$mode objfpc}
{$H+}

uses
	sdl2, poglErrors;

const
	poglMainWindowWidth = 640;
	poglMainWindowHeight = 480;

	programName = 'Pogl';

	colorBlack: longword = $FF000000;
	colorWhite: longword = $FFFFFFFF;

type
	Pixel = longword;
	TFrameBuffer = array of Pixel;

label cleanup;

var
	statusCode: integer;
	poglMainWindow: PSDL_Window;
	sdlRenderer: PSDL_Renderer;
	screenTexture: PSDL_Texture;
	frameBuffer: TFrameBuffer;
	i: integer;

procedure ClearScreen(color: Pixel);
var
	i: integer;
begin
	for i := 0 to High(frameBuffer) do
		frameBuffer[i] := color;
end;

procedure PutPixel(x, y: integer; color: Pixel);
begin
	if (x < 0) or (x >= poglMainWindowWidth) or
	   (y < 0) or (y >= poglMainWindowHeight) then
		Exit;

	frameBuffer[y * poglMainWindowWidth + x] := color;
end;

begin
	poglMainWindow := nil;
	sdlRenderer := nil;
	screenTexture := nil;

	statusCode := SDL_Init(SDL_INIT_VIDEO);
	if statusCode < 0 then
		goto cleanup;

	poglMainWindow := SDL_CreateWindow(
		programName,
		SDL_WINDOWPOS_UNDEFINED,
		SDL_WINDOWPOS_UNDEFINED,
		poglMainWindowWidth,
		poglMainWindowHeight,
		SDL_WINDOW_SHOWN
	);
	if poglMainWindow = nil then
		goto cleanup;

	sdlRenderer := SDL_CreateRenderer(
		poglMainWindow,
		-1,
		0
	);
	if sdlRenderer = nil then
		goto cleanup;

	screenTexture := SDL_CreateTexture(
		sdlRenderer,
		SDL_PIXELFORMAT_ARGB8888,
		SDL_TEXTUREACCESS_STREAMING,
		poglMainWindowWidth,
		poglMainWindowHeight
	);
	if screenTexture = nil then
		goto cleanup;

	SetLength(
		frameBuffer,
		poglMainWindowWidth * poglMainWindowHeight
	);
	ClearScreen(colorBlack);
	
	for i := -2 to 2 do begin
		PutPixel(
			poglMainWindowWidth div 2 + i,
			poglMainWindowHeight div 2,
			colorWhite
		);
		PutPixel(
			poglMainWindowWidth div 2,
			poglMainWindowHeight div 2 + i,
			colorWhite
		);
	end;


	statusCode := SDL_UpdateTexture(
		screenTexture,
		nil,
		@frameBuffer[0],
		poglMainWindowWidth * SizeOf(Pixel)
	);
	if statusCode < 0 then
		goto cleanup;

	statusCode := SDL_RenderClear(sdlRenderer);
	if statusCode < 0 then
		goto cleanup;

	statusCode := SDL_RenderCopy(
		sdlRenderer,
		screenTexture,
		nil,
		nil
	);
	if statusCode < 0 then
		goto cleanup;

	SDL_RenderPresent(sdlRenderer);

	SDL_Delay(2000);

	SDL_DestroyTexture(screenTexture);
	SDL_DestroyRenderer(sdlRenderer);
	SDL_DestroyWindow(poglMainWindow);
	SDL_Quit;

	Exit;

cleanup:
	PoglErrorHandler;

	if screenTexture <> nil then
		SDL_DestroyTexture(screenTexture);

	if sdlRenderer <> nil then
		SDL_DestroyRenderer(sdlRenderer);

	if poglMainWindow <> nil then
		SDL_DestroyWindow(poglMainWindow);

	SetLength(frameBuffer, 0);
	SDL_Quit;

	Halt(1);
end.
