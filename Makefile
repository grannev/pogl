static:
	cd src && make

clean:
	rm -r ./bin

run:
	./bin/pogl ./obj/cube.obj

