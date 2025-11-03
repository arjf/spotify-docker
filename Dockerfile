FROM archlinux:latest

# Update mirror dbs and install base dependencies
RUN pacman -Syy --noconfirm \
  base-devel \
  git \
  wget \
  curl \
  wayland \
  wayland-protocols \
  libxkbcommon \
  xorg-xwayland \
  mesa \
  vulkan-icd-loader \
  vulkan-intel \
  pipewire \
  pipewire-pulse \
  wireplumber \
  gtk3 \
  gtk4 \
  qt5-wayland \
  qt6-wayland \
  libnotify \
  dbus \
  nss \
  alsa-lib \
  libpulse \
  fontconfig \
  freetype2 \
  ttf-dejavu \
  ttf-liberation \
  sudo \
  unzip \
  mesa-utils \
  pipewire-alsa \
  spotify-launcher \
  nvidia-utils

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
  locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create a non-root user for running spotify & spicetify
RUN groupadd -g 1000 spotify
RUN useradd -m -s /bin/bash -u 1000 -g 1000 -G wheel spotify
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER spotify
WORKDIR /home/spotify

# Install Spicetify CLI
RUN curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | \
  sed 's|read -r choice < /dev/tty|choice="n"|' | bash
ENV PATH="/home/spotify/.spicetify:${PATH}"
RUN mkdir -p /home/spotify/.config/spicetify

# Copy entrypoint script
COPY --chown=spotify:spotify entrypoint.sh /home/spotify/entrypoint.sh
RUN chmod +x /home/spotify/entrypoint.sh

# Env vars for runtime integration with host
ENV HOST_UID=1000
ENV HOST_GID=1000
ENV XDG_RUNTIME_DIR=/tmp/runtime-spotify
ENV WAYLAND_DISPLAY=wayland-1
ENV XDG_SESSION_TYPE=wayland
ENV DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-spotify/dbus-session
ENV QT_QPA_PLATFORM=wayland
ENV GDK_BACKEND=wayland
ENV CLUTTER_BACKEND=wayland
ENV SDL_VIDEODRIVER=wayland
ENV MOZ_ENABLE_WAYLAND=1
# Create runtime directory and dbus directory
RUN mkdir -p /tmp/runtime-spotify /tmp/dbus

# Set Spotify to use Wayland flags
COPY --chown=spotify:spotify spotify-launcher.conf /etc/spotify-launcher.conf

# Use entrypoint script to start isolated D-Bus session and Spotify
CMD ["/home/spotify/entrypoint.sh"]
