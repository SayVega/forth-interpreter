.PHONY: setup server iex test clean db_reset seed

setup:
	mix setup
	mix compile

server:
	mix phx.server

iex:
	iex -S mix phx.server

test:
	MIX_ENV=test mix ecto.create --quiet
	MIX_ENV=test mix ecto.migrate --quiet
	mix test

db_reset:
	mix ecto.reset

seed:
	mix run priv/repo/seeds.exs

clean:
	mix clean