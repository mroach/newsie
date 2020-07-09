ARG elixir_ver=1.10

FROM elixir:${elixir_ver}-slim

RUN mix local.hex --force \
    mix local.rebar --force

# build inside the image and not on the mounted volume to prevent
# recompiles with different Elixir versions
ENV MIX_BUILD_PATH=/opt/mix/build
RUN mkdir -p /opt/mix/build

WORKDIR /opt/code

ENV MIX_ENV=test

# add config before compiling. it will likely affect compile-time options
COPY config ./config
COPY mix.exs mix.lock ./

RUN mix do deps.get --only $MIX_ENV, deps.compile

VOLUME /opt/code
