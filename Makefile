all:
	openscad --export-format=binstl -D model_type=1 -o stl/sword_handle.stl sword_handle.scad
	openscad --export-format=binstl -D model_type=2 -o stl/sword_apple.stl sword_handle.scad
	openscad --export-format=binstl -D model_type=3 -o stl/sword_plug.stl sword_handle.scad

clean:
	-rm -rf stl/*

.PHONY: all clean
