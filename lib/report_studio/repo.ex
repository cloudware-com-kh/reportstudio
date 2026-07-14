defmodule ReportStudio.Repo do
  use Ecto.Repo,
    otp_app: :report_studio,
    adapter: Ecto.Adapters.Postgres
end
