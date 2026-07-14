defmodule ReportplayWeb.PageController do
  use ReportplayWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def report(conn, _params) do
    assigns = %{student: %{name: "Cham Roeun"}}

    ReportplayWeb.PageHTML.report(assigns)
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> IO.inspect()

    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> render(:report, assigns)
  end
end
