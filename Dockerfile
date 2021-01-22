FROM elixir:1.11-alpine

RUN mkdir -p /app
WORKDIR /app

ENV LANG C.UTF-8

# Install Phoenix deps
RUN mix local.hex --force
RUN mix local.rebar --force

CMD ["mix", "phx.server"]