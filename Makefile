all:
	if [ -d "bin" ]; then rm -r bin; fi;
	mkdir bin
	cp -r shapes bin/shapes
	cp new.xml bin
	
	valac *.vala geometry/*.vala -o bin/diagram --pkg=gtk+-3.0 --pkg=libxml-2.0 --pkg=librsvg-2.0 --pkg=pangocairo --pkg=gee-1.0
