# Report Studio

Report Studio is a lightweight Phoenix library and generator for scaffolding custom, Tailwind-powered PDF reports using Gotenberg.

## Features

- **Dynamic Mix Generator:** Scaffolds custom reports in your host application with zero boilerplate.
- **Dedicated Tailwind Builds:** Automatically configures standalone Tailwind entry points for each report.
- **Gotenberg Integration:** Provides an easy-to-use API to convert your HEEx templates and CSS into PDFs.

## Installation

Add `:report_studio` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:report_studio, git: "https://github.com/cloudware-com-kh/reportstudio.git", tag: "main"},
    # Make sure you include igniter if you want to use the generators!
    {:igniter, "~> 0.8"}
  ]
end
```

## Configuration

In your `config/config.exs`, configure the URL and basic auth credentials for your Gotenberg instance:

```elixir
config :report_studio,
  gotenberg_url: System.get_env("GOTENBERG_URL") || "https://gotenberg.domain.com/forms/chromium/convert/html",
  gotenberg_auth: {:basic, "admin:admin@reportengine"}
```

## Usage

### 1. Generate a New Report

Use the included Mix task to scaffold a new report. For example, to create an `invoice` report:

```bash
mix report_studio.gen.report invoice
```

This task will automatically:
- Create a dedicated HEEx template at `lib/your_app_web/controllers/page_html/invoice.html.heex`
- Create a dedicated Tailwind CSS file at `assets/css/invoice.css`
- Append the `invoice` and `invoice_preview` routes to your `router.ex`
- Append the controller actions to your `page_controller.ex`
- Safely update your `mix.exs` aliases and `dev.exs` watchers to compile the new Tailwind CSS for the report.

### 2. View your Report

Start your Phoenix server:
```bash
mix phx.server
```
Navigate to `/invoice` to see the raw HTML report, or `/invoice-preview` to view the generated PDF via Gotenberg!

### 3. Using the PDFGenerator Manually

If you prefer to generate PDFs manually without using the scaffolder, you can use `ReportStudio.PDFGenerator`:

```elixir
# 1. Render your template to a string/iodata
template = YourAppWeb.PageHTML.invoice(assigns)

# 2. Get the absolute path to your compiled CSS
css_path = Application.app_dir(:your_app, "priv/static/assets/css/invoice.css")

# 3. Generate the PDF
{:ok, pdf_binary} = ReportStudio.PDFGenerator.generate_pdf(template, css_path)

# 4. (Optional) Send inline to the client in a controller
ReportStudio.PDFGenerator.send_inline_pdf(conn, pdf_binary, "invoice.pdf")
```
