# syntax=docker/dockerfile:experimental
# ================================
# Build image
# ================================
FROM swift:5.5-focal as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
COPY ./Modules/Core/Package.* ./Modules/Core/
COPY ./Modules/DomainEntity/Package.* ./Modules/DomainEntity/
COPY ./Modules/Endpoint/Package.* ./Modules/Endpoint/
COPY ./Modules/LoggingDiscord/Package.* ./Modules/LoggingDiscord/

RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations and test discovery
RUN --mount=type=cache,target=/build/.build \
  swift build -c release -Xswiftc -g

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN --mount=type=cache,target=/build/.build \
  cp "$(swift build --package-path /build -c release --show-bin-path)/Run" ./

# Uncomment the next line if you need to load resources from the `Public` directory.
# Ensure that by default, neither the directory nor any of its contents are writable.
#RUN mv /build/Public ./Public && chmod -R a-w ./Public

# ================================
# Run image
# ================================
FROM swift:5.5-focal-slim

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && rm -r /var/lib/apt/lists/*

# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=vapor:vapor /staging /app

# Ensure all further commands run as the vapor user
USER vapor:vapor

ENV PORT=8080
# Let Docker bind to port 8080
EXPOSE $PORT

RUN echo "./Run serve --env production --hostname 0.0.0.0 --port \$PORT" > ./entrypoint.sh && \
  chmod +x ./entrypoint.sh
ENTRYPOINT "./entrypoint.sh"
