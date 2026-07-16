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
    |> assert_has_patch(".igniter.exs", """
    |  extensions: [{Igniter.Extensions.Phoenix, []}],
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

  test "in a real Phoenix app layout with apply_igniter/1, the files remain in the controllers folder" do
    assert {:ok, igniter, _} =
             phx_test_project()
             |> Igniter.compose_task("report_studio.gen.report", ["student"])
             |> apply_igniter()

    created_paths = Map.keys(igniter.rewrite.sources)

    # They should not be at the root of test_web/
    refute "lib/test_web/student_controller.ex" in created_paths
    refute "lib/test_web/student_html.ex" in created_paths

    # They should be inside controllers/
    assert "lib/test_web/controllers/student_controller.ex" in created_paths
    assert "lib/test_web/controllers/student_html.ex" in created_paths
    assert "lib/test_web/controllers/student_html/index.html.heex" in created_paths
  end
end
