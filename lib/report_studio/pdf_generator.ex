defmodule ReportStudio.PDFGenerator do
  @gotenberg_url "https://gotenberg.cloudware.com.kh/forms/chromium/convert/html"
  @auth {:basic, "admin:admin@reportengine"}

  @doc """
  Generates a PDF from a rendered Phoenix template and a CSS file path.
  - `template` is a rendered Phoenix template (e.g. from a component or view function).
  - `css_path_relative` is the path to the CSS file inside `priv/static/assets/`, for example `"css/employee.css"`.
  """
  def generate_pdf(template, css_path_relative) do
    html_binary =
      template
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    css_path = Application.app_dir(:report_studio, "priv/static/assets/#{css_path_relative}")
    css_binary = File.read!(css_path)

    generate_pdf_from_html(html_binary, css_binary)
  end

  @doc """
  Generates a PDF binary from HTML and CSS using Gotenberg.
  """
  def generate_pdf_from_html(html_binary, css_binary) do
    case Req.post(@gotenberg_url,
           auth: @auth,
           headers: [{"gotenberg-timeout", "300s"}],
           receive_timeout: 300_000,
           form_multipart: [
             files: {html_binary, filename: "index.html"},
             files: {css_binary, filename: "report.css"},
             preferCssPageSize: "true"
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: pdf_binary}} ->
        {:ok, pdf_binary}

      {:error, reason} ->
        {:error, reason}

      response ->
        {:error, response}
    end
  end

  @doc """
  Helper function to send the PDF binary as an inline response to the client.
  Handles both `{:ok, pdf_binary}` and `{:error, reason}` tuples, as well as raw binaries.
  """
  def send_inline_pdf(conn, result_or_binary, filename \\ "report.pdf")

  def send_inline_pdf(conn, {:ok, pdf_binary}, filename) do
    conn
    |> Plug.Conn.put_resp_content_type("application/pdf")
    |> Plug.Conn.put_resp_header("content-disposition", "inline; filename=\"#{filename}\"")
    |> Plug.Conn.send_resp(200, pdf_binary)
  end

  def send_inline_pdf(conn, {:error, reason}, _filename) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(500, "Failed to generate PDF: #{inspect(reason)}")
  end

  def send_inline_pdf(conn, pdf_binary, filename) when is_binary(pdf_binary) do
    send_inline_pdf(conn, {:ok, pdf_binary}, filename)
  end
end
