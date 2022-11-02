# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl git-all build-essential
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install afl
COPY . /rawloader
WORKDIR /rawloader/fuzz/
RUN ${HOME}/.cargo/bin/cargo afl build
#WORKDIR /rawloader/fuzz/in
#RUN echo ' ' >> one.txt
WORKDIR /rawloader/fuzz
#ENTRYPOINT ["cargo", "afl", "fuzz", "-i", "/rawloader/fuzz/in", "-o", "/rawloader/fuzz/out"]
#CMD ["/rawloader/fuzz/target/debug/fuzz-rawloader-decoders"]

# Package Stage
FROM ubuntu:20.04
COPY --from=builder /rawloader/fuzz/target/debug/ /
WORKDIR /in
RUN echo ' ' >> one.txt
#ENTRYPOINT ["cargo", "afl", "fuzz", "-i", "/in", "-o", "/out"]
#CMD ["/target/debug/fuzz"]