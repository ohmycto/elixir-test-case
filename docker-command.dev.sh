#!/bin/sh

export MIX_ENV=dev
mix deps.get
mix ecto.migrate
mix phx.server