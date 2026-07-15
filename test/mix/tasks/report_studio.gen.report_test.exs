defmodule Mix.Tasks.ReportStudio.Gen.ReportTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "it generates all report files" do
    # generate a test project
    test_project()
    # run our task
    |> Igniter.compose_task("report_studio.gen.report", ["student"])
    # assert the files are created
    |> assert_creates("lib/test_web/controllers/page_controller.ex")
    |> assert_creates("lib/test_web/controllers/page_html/student.html.heex")
    |> assert_creates("assets/css/student.css")
  end

  test "it moves PageHTML if it is located directly in the web directory" do
    test_project()
    # run our task
    |> Igniter.compose_task("report_studio.gen.report", ["student"])
    # assert the files are moved to the controllers directory
    |> refute_creates("lib/test_web/page_html.ex")
    |> refute_creates("lib/test_web/page_html/old.html.heex")
    # assert the new report files are created
    |> assert_creates("lib/test_web/controllers/page_html/student.html.heex")
    |> assert_creates("assets/css/student.css")
  end
end
