# Use Swift official image as the base image
FROM swift:5.8-jammy

# Install required packages
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libbsd-dev \
    linux-libc-dev \
    build-essential \
    pkg-config \
    poppler-utils \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy package files first to cache dependencies
COPY Package.swift Package.resolved ./

# Copy the rest of the project
COPY . .

# Build the project
RUN swift build -c release

# Set the binary as the entrypoint
CMD [".build/release/CoreMLDemo"]