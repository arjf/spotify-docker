# Spotify in Docker (Wayland)

Run Spotify in a Docker container with Wayland display support and Spicetify theming.

## Features

- **Wayland Native**: Full Wayland protocol support, launches as a regular app in your wayland session.
- **Audio**: PipeWire/PulseAudio passthrough
- **Spicetify Support**: Theme and customize Spotify

## Setup

1. Fill the .env file with your desired configuration.
Set these in `.env`
```
CONF_DIR=""
LOCAL_DIR=""
HOST_UID=""
HOST_GID=""
```
2. Install the app
```bash
make install
```
Make installs the spotify-docker script to \$HOME/.local/bin and config values to ~/.config/spotify-docker/

you may need to add ~/.local/bin to your PATH if it's not already there.

```bash
make install-desktop
```
This installs a desktop file to launch Spotify from your application menu.

3. Launch Spotify
```bash
spotify-docker launch

```
or by the desktop file

This opens Spotify in the container, if it does not exist it will create and start the container first.
You can use the desktop file or an alias to launch.


## Available Commands

| Command | Description |
|---------|-------------|
| `spotify-docker create` | Start container in daemon mode |
| `spotify-docker launch` | Launch Spotify in running container |
| `spotify-docker build` | Build or rebuild the container image |
| `spotify-docker shell` | Open bash shell in container |
| `spotify-docker spicetify ...` | Run spicetify command |
| `spotify-docker stop` | Stop the container |
| `spotify-docker logs` | Show container logs |
| `spotify-docker down` | Remove container |
| `spotify-docker help` | Show help message |


## GPU Support
If you do not have an nvidia GPU,

Remove the line `runtime: nvidia` from `\$HOME/.config/spotify-docker/docker-compose.yml` under the container definition.
Modify as required by your gpu setup.

For NVIDIA, you may need additional configuration:

If you are not using nvidia-container-toolkit, add the following to `\$HOME/.config/spotify-docker/docker-compose.yml` under the container defintion, and remove `runtime: nvidia`.
```yaml
deploy:
  resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
```

## Contributing

Feel free to submit issues or pull requests for improvements!

## License

This project is provided as-is for personal use.

## Credits

- [Spicetify](https://spicetify.app/)
- [Spotify Launcher](https://github.com/kpcyrd/spotify-launcher)
