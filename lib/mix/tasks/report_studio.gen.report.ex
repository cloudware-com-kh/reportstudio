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
    module_name_suffix = Macro.camelize(name)
    human_name = name |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join(" ")

    # 1. Define paths and names
    controller_path = "lib/report_studio_web/controllers/#{name}_report_controller.ex"
    html_path = "lib/report_studio_web/controllers/#{name}_report_html.ex"
    heex_path = "lib/report_studio_web/controllers/#{name}_report_html/report.html.heex"
    css_path = "assets/css/#{name}_report.css"

    controller_content = """
    defmodule ReportStudioWeb.Controllers.#{module_name_suffix}ReportController do
      use ReportStudioWeb, :controller

      def show(conn, _params) do
        assigns = %{student: %{name: "Cham Roeun"}}

        conn
        |> put_root_layout(false)
        |> put_layout(false)
        |> render(:report, assigns)
      end
    end
    """

    html_content = """
    defmodule ReportStudioWeb.Controllers.#{module_name_suffix}ReportHTML do
      use ReportStudioWeb, :html

      embed_templates "#{name}_report_html/*"
    end
    """

    heex_content = """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <link rel="stylesheet" href={~p"/assets/css/#{name}_report.css"} />
      </head>
      <body class="bg-white">
        <div class="w-[210mm] h-[297mm] p-[20mm]">
          <h1 class="text-3xl font-bold">#{human_name} Report</h1>
          <p>Name: {@student.name}</p>
        </div>
      </body>
    </html>
    """

    css_content = """
    @import "tailwindcss" source(none);
    @source "../../lib/report_studio_web/controllers/#{name}_report_html/report.html.heex";
    """

    route_code =
      "get \"/#{name}_report\", Controllers.#{module_name_suffix}ReportController, :show"

    # 2. Add files and configurations
    tailwind_key = String.to_atom("#{name}_report")
    watcher_key = String.to_atom("tailwind_#{name}_report")

    igniter
    # Create new files
    |> Igniter.create_new_file(controller_path, controller_content)
    |> Igniter.create_new_file(html_path, html_content)
    |> Igniter.create_new_file(heex_path, heex_content)
    |> Igniter.create_new_file(css_path, css_content)
    # Append route to router.ex using manual update to target the ReportStudioWeb scope
    |> Igniter.update_file("lib/report_studio_web/router.ex", fn source ->
      content = Rewrite.Source.get(source, :content)

      new_content =
        if String.contains?(content, route_code) do
          content
        else
          String.replace(
            content,
            "scope \"/\", ReportStudioWeb do\n    pipe_through :browser",
            "scope \"/\", ReportStudioWeb do\n    pipe_through :browser\n    #{route_code}"
          )
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
           --input=assets/css/#{name}_report.css
           --output=priv/static/assets/css/#{name}_report.css
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
        if String.contains?(content, "tailwind #{name}_report") do
          content
        else
          content
          |> String.replace(
            "\"tailwind report_studio\",",
            "\"tailwind report_studio\", \"tailwind #{name}_report\","
          )
          |> String.replace(
            "\"tailwind report_studio --minify\",",
            "\"tailwind report_studio --minify\",\n        \"tailwind #{name}_report --minify\","
          )
        end

      Rewrite.Source.update(source, :content, new_content)
    end)
  end
end
