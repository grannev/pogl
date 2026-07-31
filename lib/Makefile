FPC := fpc
TARGET := point
SRC := point.pas

SDL_UNITS := ./SDL2-for-Pascal/units
BUILD := build

all:
	mkdir -p $(BUILD)
	$(FPC) -O2 \
		-Fu$(SDL_UNITS) \
		-FU$(BUILD) \
		-FE$(BUILD) \
		-o$(TARGET) \
		$(SRC)

run: all
	./$(BUILD)/$(TARGET)

clean:
	rm -rf $(BUILD)
