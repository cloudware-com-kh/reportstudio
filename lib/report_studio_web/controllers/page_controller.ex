defmodule ReportStudioWeb.PageController do
  use ReportStudioWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def employee(conn, _params) do
    assigns = %{
      employees: [
        %{name: "Cham Roeun"},
        %{name: "John Doe"}
      ]
    }

    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> render(:employee, assigns)
  end

  # Render the employee preview PDF
  def employee_preview(conn, _params) do
    assigns = %{
      employees: [
        %{name: "Cham Roeun"},
        %{name: "John Doe"}
      ]
    }

    html_string =
      ReportStudioWeb.PageHTML.employee(assigns)
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    # 2. Read the compiled Tailwind CSS safely
    css_path = Application.app_dir(:report_studio, "priv/static/assets/css/employee.css")
    css_binary = File.read!(css_path)
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
  end
end
