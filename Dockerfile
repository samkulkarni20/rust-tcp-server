## Builder
FROM rust:1.71.0-slim as builder

WORKDIR /usr/src

# Create a blank project
RUN USER=root cargo new rust-tcp-server

# Copy Cargo.toml and Cargo.lock to cache the dependencies
COPY Cargo.toml Cargo.lock /usr/src/rust-tcp-server/

# Change to project directory
WORKDIR /usr/src/rust-tcp-server

## Install target platform for cross-compilation for alpine
RUN rustup target add x86_64-unknown-linux-musl

# Build the project to cache dependencies
RUN cargo build --target x86_64-unknown-linux-musl --release

# Copy the source
COPY src /usr/src/rust-tcp-server/src

# Touch main.rs to prevent cached release build
RUN touch /usr/src/rust-tcp-server/src/main.rs

# Build the project
RUN cargo build --target x86_64-unknown-linux-musl --release

## Runtime image
FROM alpine

# RUN apk --update add libstdc++ gcompat

COPY --from=builder /usr/src/rust-tcp-server/target/x86_64-unknown-linux-musl/release/rust-tcp-server /rust-tcp-server

CMD ["/rust-tcp-server"]