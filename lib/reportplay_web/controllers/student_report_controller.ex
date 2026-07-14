defmodule ReportplayWeb.Controllers.StudentReportController do
  use ReportplayWeb, :controller

  def show(conn, _params) do
    assigns = %{student: %{name: "Cham Roeun"}}

    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> render(:report, assigns)
  end
end
