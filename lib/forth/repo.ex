defmodule Forth.Repo do
  use Ecto.Repo,
    otp_app: :forth_web,
    adapter: Ecto.Adapters.Postgres
end
