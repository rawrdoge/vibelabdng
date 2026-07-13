# DNGLab - static musl Linux build
#
# Produces a fully static `dnglab` binary (x86_64-unknown-linux-musl) with no
# glibc/runtime dependencies, suitable for minimal containers and the
# RawImport pipeline.
#
# Build:
#   docker build -t dnglab -f Dockerfile .
# The static binary is emitted to /usr/local/bin/dnglab inside the image.

FROM rust:1.89-bookworm AS builder

# musl target + a C cross-compiler (some crates build C shims even under musl)
RUN apt-get update \
    && apt-get install -y --no-install-recommends musl-tools clang \
    && rm -rf /var/lib/apt/lists/*
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /src
COPY . .

# Build the release binary for the musl target, fully static.
# CC_x86_64_unknown_linux_musl points the C compiler at musl-gcc so any C
# build scripts link against musl instead of glibc.
ENV CC_x86_64_unknown_linux_musl=musl-gcc
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+crt-static"

RUN cargo build --release --target x86_64-unknown-linux-musl --bin dnglab

# Minimal runtime image: just the static binary.
FROM alpine:3.20 AS runtime
RUN apk add --no-cache ca-certificates
COPY --from=builder \
    /src/target/x86_64-unknown-linux-musl/release/dnglab \
    /usr/local/bin/dnglab
ENTRYPOINT ["/usr/local/bin/dnglab"]