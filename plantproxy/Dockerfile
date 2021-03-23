# syntax = docker/dockerfile:experimental
FROM elixir:1.11.2-alpine as builder
ARG MIX_ENV=prod
RUN apk add --no-cache --update git openssh-client
WORKDIR /app
RUN mix do local.hex --force, local.rebar --force
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
COPY ./mix.exs ./mix.lock ./
COPY ./config ./config
ENV MIX_ENV=prod
RUN --mount=type=ssh mix do deps.get --only $MIX_ENV, deps.compile
COPY lib lib
RUN mix compile
COPY ./rel ./rel
RUN MIX_ENV=prod mix release > /dev/null
# FROM alpine:3.12 AS release
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/plantproxy/ .
ENTRYPOINT ["./bin/plantproxy"]
CMD [""]
