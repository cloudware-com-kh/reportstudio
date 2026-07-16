defmodule Mix.Tasks.ReportStudio.Gen.ReportTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "it generates all report files" do
    # generate a test project
    test_project()
    # run our task
    |> Igniter.compose_task("report_studio.gen.report", ["student"])
    # assert the files are created
    |> assert_creates("lib/test_web/controllers/student_controller.ex")
    |> assert_creates("lib/test_web/controllers/student_html.ex")
    |> assert_creates("lib/test_web/controllers/student_html/index.html.heex")
    |> assert_creates("assets/css/student.css")
    |> assert_has_patch("config/config.exs", """
    |config :report_studio,
    |  gotenberg_url:
    |    System.get_env("GOTENBERG_URL") || "https://gotenberg.domain.com/forms/chromium/convert/html",
    |  gotenberg_auth: {:basic, "admin:admin@reportengine"}
    """)
  end

  test "it can generate multiple independent reports" do
    test_project()
    |> Igniter.compose_task("report_studio.gen.report", ["student"])
    |> Igniter.compose_task("report_studio.gen.report", ["invoice"])
    |> assert_creates("lib/test_web/controllers/student_controller.ex")
    |> assert_creates("lib/test_web/controllers/invoice_controller.ex")
    |> assert_creates("lib/test_web/controllers/student_html.ex")
    |> assert_creates("lib/test_web/controllers/invoice_html.ex")
    |> assert_creates("lib/test_web/controllers/student_html/index.html.heex")
    |> assert_creates("lib/test_web/controllers/invoice_html/index.html.heex")
  end
end
