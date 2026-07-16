defmodule ReportStudio.PDFGenerator do
  @doc """
  Generates a PDF from a rendered Phoenix template and a CSS file path.
  - `template` is a rendered Phoenix template (e.g. from a component or view function).
  - `css_path` is the absolute path to the CSS file.
  """
  def generate_pdf(template, css_path) do
    html_binary =
      template
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    css_binary = File.read!(css_path)

    generate_pdf_from_html(html_binary, css_binary)
  end

  @doc """
  Generates a PDF binary from HTML and CSS using Gotenberg.
  """
  def generate_pdf_from_html(html_binary, css_binary) do
    # The JS payload you want to inject
    wait_script = """
      <script>
        window.reportReady = false;
        Promise.all(Array.from(document.images).filter(img => !img.complete).map(img => new Promise(resolve => { img.onload = img.onerror = resolve; }))).then(() => {
          document.fonts.ready.then(() => { window.reportReady = true; });
        });
      </script>
    </body>
    """

    # Replace the closing </body> tag with your script + the closing tag
    final_html = String.replace(html_binary, "</body>", wait_script)

    case Req.post(gotenberg_url(),
           auth: gotenberg_auth(),
           headers: [{"gotenberg-timeout", "300s"}],
           receive_timeout: 300_000,
           form_multipart: [
             files: {final_html, filename: "index.html"},
             files: {css_binary, filename: "report.css"},
             preferCssPageSize: "true",
             # Skip the unreliable network idle waits
             skipNetworkIdleEvent: "true",
             skipNetworkAlmostIdleEvent: "true",
             # Wait for our custom Javascript flag
             waitForExpression: "window.reportReady === true"
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

  defp gotenberg_url do
    Application.get_env(
      :report_studio,
      :gotenberg_url,
      "https://gotenberg.domain.com/forms/chromium/convert/html"
    )
  end

  defp gotenberg_auth do
    Application.get_env(:report_studio, :gotenberg_auth, {:basic, "admin:admin@reportengine"})
  end

  @doc """
  Helper function to render a report HTML template without a layout.
  Intended to be called from your Phoenix controllers.
  """
  def render_report(conn, template_name, assigns) do
    conn
    |> Phoenix.Controller.put_layout(false)
    |> Phoenix.Controller.render(template_name, assigns)
  end
end
