.PHONY: setup deps db_create db_reset migrate seed server iex test clean

setup: deps db_create migrate

deps:
	mix deps.get

db_create:
	mix ecto.create

db_reset:
	mix ecto.drop
	mix ecto.create
	mix ecto.migrate

migrate:
	mix ecto.migrate

seed:
	mix run priv/repo/seeds.exs

server:
	mix phx.server

iex:
	iex -S mix phx.server

test:
	MIX_ENV=test mix ecto.create --quiet
	MIX_ENV=test mix ecto.migrate --quiet
	mix test

clean:
	mix clean