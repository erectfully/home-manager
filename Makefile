move_into_home_directory:
	cp -r * ~/.config/home-manager/

activate:
	nix run .#activate
