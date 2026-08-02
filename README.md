# POGL

POGL - Wavefront OBJ files render, written in Free Pascal using SDL2 lib and
[SDL2-for-Pascal][https://github.com/PascalGameDevelopment/SDL2-for-Pascal]
repository.

## Requirements

- Free Pascal Compiler
- GNU Make
- GCC
- SDL2

Pascal-units for SDL2 already in directory `lib/SDL2-for-Pascal`.

## Building

From repo root run:

```bash
make
```

Application will appear here:

```text
bin/pogl
```

## Running

First argument is a path to OBJ file:

```bash
./bin/pogl ./obj/african_head.obj
```

## Controls

| Keys | Action |
|---|---|
| `Left Arrow` / `Right Arrow` | Turn around Y axis |
| `Up Arrow` / `Down Arrow` | Turn around X axis |
| `Page Up` / `Page Down` | Turn around Z axis |
| `Escape` | Close application |

You can keep pressed several buttons at the same time.

## Project structure

```text
src/    program main file & Makefile
lib/    OBJ parser, maths, graphics & SDL2-units
obj/    models example
bin/    results of building
```
