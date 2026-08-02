PC := fpc
TARGET := bin/pogl
SRC := pogl.pas

GCC_LIBDIR := $(shell dirname $$(gcc -print-file-name=crtbeginS.o))
SDL_UNITS := ../lib/SDL2-for-Pascal/units
POGL_UNITS := ../lib
BUILD := bin

static: all

all: clean dir-bin build

dir-bin:
	mkdir -p $(BUILD)

build:
	$(PC) -g -O2 \
		-Fl$(GCC_LIBDIR) \
		-Fu$(SDL_UNITS) \
		-Fu$(POGL_UNITS) \
		-FU$(BUILD) \
		-FE$(BUILD) \
		-o$(TARGET) \
		$(SRC)

run: build
	./$(BUILD)/$(TARGET)

clean:
	rm -rf $(BUILD)
