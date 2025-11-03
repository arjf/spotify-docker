.PHONY: help build install uninstall dev install-build install-desktop
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "Spotify Docker - Makefile Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

build:
	@echo "Building Spotify Docker image..."
	docker-compose -f ./docker-compose-build.yml build

install:
	@echo "Installing Spotify Docker..."
	# script
	mkdir -p ~/.local/bin
	cp ./spotify-docker ~/.local/bin/spotify-docker
	chmod +x ~/.local/bin/spotify-docker

	# config
	mkdir -p ~/.config/spotify-docker
	cp docker-compose.yml ~/.config/spotify-docker/docker-compose.yml
	if [ ! -f .env ]; then \
		echo "Create the .env file, refer to the readme for instructions."; \
		exit 1; \
	fi
	cp .env ~/.config/spotify-docker/.env

	@echo "Installation complete. You may need to add ~/.local/bin to path."

uninstall:
	@echo "Uninstalling Spotify Docker..."
	# removing files
	rm ~/.local/bin/spotify-docker
	@echo "Uninstallation complete. You may want to remove the configuration directory at ~/.config/spotify-docker manually."

dev: ## Run using local build
	@echo "Starting Spotify Docker."
	docker-compose -f ./docker-compose-build.yml build
	docker-compose -f ./docker-compose-build.yml up -d
	docker-compose -f ./docker-compose-build.yml logs -f

install-build: ## Install locally built version
	@echo "Installing Spotify Docker using locally built image..."

	# script
	mkdir -p ~/.local/bin
	cp ./spotify-docker ~/.local/bin/spotify-docker
	chmod +x ~/.local/bin/spotify-docker

	# config
	mkdir -p ~/.config/spotify-docker
	cp docker-compose-build.yml ~/.config/spotify-docker/docker-compose.yml
	if [ ! -f .env ]; then \
		echo "Create the .env file, refer to the readme for instructions."; \
		exit 1; \
	fi
	cp .env ~/.config/spotify-docker/.env

	# build image
	docker-compose -f ~/.config/spotify-docker/docker-compose.yml build

	@echo "Installation complete. You may need to add ~/.local/bin to path."

install-desktop: ## Install desktop file
	@echo "Installing Spotify Docker desktop file..."
	mkdir -p ~/.local/share/applications
	sed "s|@HOME@|$$HOME|g" spotify-docker.desktop > ~/.local/share/applications/spotify-docker.desktop
	@echo "Desktop file installed. In some cases you may need to log out and back in to see it in your application menu."
