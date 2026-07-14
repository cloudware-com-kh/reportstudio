defmodule ReportStudioWeb.Controllers.StudentReportController do
  use ReportStudioWeb, :controller

  def show(conn, _params) do
    assigns = %{student: %{name: "Cham Roeun"}}

    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> render(:report, assigns)
  end
end
