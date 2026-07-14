defmodule ReportplayWeb.Controllers.EmployeeReportController do
  use ReportplayWeb, :controller

  def show(conn, _params) do
    assigns = %{
      employees: [
        %{name: "Cham Roeun"},
        %{name: "John Doe"}
      ]
    }

    html_string =
      ReportplayWeb.Controllers.EmployeeReportHTML.report(assigns)
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    # 2. Read the compiled Tailwind CSS safely
    css_path = Application.app_dir(:reportplay, "priv/static/assets/css/employee_report.css")
    css_binary = File.read!(css_path)
    IO.inspect(html_string)
    # 2. Fire the request using form_multipart
    # Gotenberg expects the field name for all attachments to be "files"
    case Req.post("https://gotenberg.cloudware.com.kh/forms/chromium/convert/html",
           auth: {:basic, "admin:admin@reportengine"},
           form_multipart: [
             files: {html_string, filename: "index.html"},
             files: {css_binary, filename: "report.css"},
             preferCssPageSize: "true"
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: pdf_binary}} ->
        File.write!("report.pdf", pdf_binary)
        {:ok, pdf_binary}

      {:error, reason} ->
        {:error, reason}

      response ->
        raise "Unexpected response: #{inspect(response)}"
        {:error, :unknown}
    end

    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> render(:report, assigns)
  end
end
