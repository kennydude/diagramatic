all:
	valac *.vala -o diagram --pkg=gtk+-3.0 --pkg=libxml-2.0 --pkg=librsvg-2.0 --pkg=pangocairo
