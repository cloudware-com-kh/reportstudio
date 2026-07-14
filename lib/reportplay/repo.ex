defmodule Reportplay.Repo do
  use Ecto.Repo,
    otp_app: :reportplay,
    adapter: Ecto.Adapters.Postgres
end
