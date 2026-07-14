defmodule Mix.Tasks.ReportStudio.Gen.Report.Docs do
  @moduledoc false

  @spec short_doc() :: String.t()
  def short_doc do
    "Scaffolds a new dedicated report page with its own custom Tailwind build"
  end

  @spec example() :: String.t()
  def example do
    "mix report_studio.gen.report student"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    Generates controller, HTML module, HEEx template, dedicated stylesheet, route,
    and tailwind.config for a dedicated standalone report.

    ## Example

    ```sh
    #{example()}
    ```
    """
  end
end

defmodule Mix.Tasks.ReportStudio.Gen.Report do
  @shortdoc "#{__MODULE__.Docs.short_doc()}"
  @moduledoc __MODULE__.Docs.long_doc()

  use Igniter.Mix.Task

  @impl Igniter.Mix.Task
  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      group: :report_studio,
      adds_deps: [],
      installs: [],
      example: __MODULE__.Docs.example(),
      positional: [:name],
      composes: [],
      schema: [],
      defaults: [],
      aliases: [],
      required: []
    }
  end

  @impl Igniter.Mix.Task
  def igniter(igniter) do
    raw_name = igniter.args.positional.name
    name = Macro.underscore(raw_name)
    human_name = name |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join(" ")

    # 1. Define paths and names
    heex_path = "lib/report_studio_web/controllers/page_html/#{name}.html.heex"
    css_path = "assets/css/#{name}.css"

    heex_content = """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <link rel="stylesheet" href={~p"/assets/css/#{name}.css"} />
        <link rel="stylesheet" href="report.css" />
        <style>
          @page { size: A4 portrait; margin: 0; }
          body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        </style>
      </head>
      <!-- Add flex-col and gap-12 here so the pages stack visually in your browser -->
      <body class="bg-slate-300 print:bg-white flex flex-col items-center py-12 gap-12 print:py-0 print:gap-0 print:block">
        <!-- Loop the PAPER wrapper, not just the content -->
        <div
          :for={#{name} <- @#{name}s}
          class="w-[210mm] h-[297mm] p-[20mm] bg-white shadow-2xl print:shadow-none box-border relative break-after-page"
        >
          <h1 class="text-3xl font-bold">#{human_name} Report</h1>
          <p>Name: {#{name}.name}</p>
        </div>
      </body>
    </html>
    """

    css_content = """
    @import "tailwindcss" source(none);
    @source "../../lib/report_studio_web/controllers/page_html/#{name}.html.heex";
    """

    route_code = """
        get "/#{name}", PageController, :#{name}
        get "/#{name}-preview", PageController, :#{name}_preview
    """

    controller_actions = """

      def #{name}(conn, _params) do
        assigns = %{
          #{name}s: [
            %{name: "Cham Roeun"},
            %{name: "John Doe"}
          ]
        }

        render_report(conn, :#{name}, assigns)
      end

      def #{name}_preview(conn, _params) do
        assigns = %{
          #{name}s: [
            %{name: "Cham Roeun"},
            %{name: "John Doe"}
          ]
        }

        template = ReportStudioWeb.PageHTML.#{name}(assigns)

        result = ReportStudio.PDFGenerator.generate_pdf(template, "css/#{name}.css")
        ReportStudio.PDFGenerator.send_inline_pdf(conn, result, "report.pdf")
      end
    """

    # 2. Add files and configurations
    tailwind_key = String.to_atom(name)
    watcher_key = String.to_atom("tailwind_#{name}")

    igniter
    # Create new files
    |> Igniter.create_new_file(heex_path, heex_content)
    |> Igniter.create_new_file(css_path, css_content)
    # Append route to router.ex using manual update to target the ReportStudioWeb scope
    |> Igniter.update_file("lib/report_studio_web/router.ex", fn source ->
      content = Rewrite.Source.get(source, :content)

      new_content =
        if String.contains?(content, "get \"/#{name}\", PageController") do
          content
        else
          String.replace(
            content,
            "scope \"/\", ReportStudioWeb do\n    pipe_through :browser",
            "scope \"/\", ReportStudioWeb do\n    pipe_through :browser\n#{route_code}"
          )
        end

      Rewrite.Source.update(source, :content, new_content)
    end)
    # Append actions to page_controller.ex
    |> Igniter.update_file("lib/report_studio_web/controllers/page_controller.ex", fn source ->
      content = Rewrite.Source.get(source, :content)

      new_content =
        if String.contains?(content, "def #{name}(") do
          content
        else
          content
          |> String.trim_trailing()
          |> String.replace_suffix("end", controller_actions <> "\nend")
        end

      Rewrite.Source.update(source, :content, new_content)
    end)
    # Configure config/config.exs
    |> Igniter.Project.Config.configure(
      "config.exs",
      :tailwind,
      [tailwind_key],
      {:code,
       Sourceror.parse_string!("""
       [
         args: ~w(
           --input=assets/css/#{name}.css
           --output=priv/static/assets/css/#{name}.css
         ),
         cd: Path.expand("..", __DIR__),
         env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
       ]
       """)}
    )
    # Configure config/dev.exs watcher
    |> Igniter.Project.Config.configure(
      "dev.exs",
      :report_studio,
      [ReportStudioWeb.Endpoint, :watchers, watcher_key],
      {:code,
       Sourceror.parse_string!("{Tailwind, :install_and_run, [:#{tailwind_key}, ~w(--watch)]}")}
    )
    # Patch mix.exs
    |> Igniter.update_file("mix.exs", fn source ->
      content = Rewrite.Source.get(source, :content)

      new_content =
        if String.contains?(content, "\"tailwind #{name}\"") do
          content
        else
          content
          |> String.replace(
            "\"tailwind report_studio\",",
            "\"tailwind report_studio\", \"tailwind #{name}\","
          )
          |> String.replace(
            "\"tailwind report_studio --minify\",",
            "\"tailwind report_studio --minify\",\n        \"tailwind #{name} --minify\","
          )
        end

      Rewrite.Source.update(source, :content, new_content)
    end)
  end
end
