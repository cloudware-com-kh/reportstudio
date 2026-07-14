defmodule Mix.Tasks.ReportStudio.Gen.ReportTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "it generates all report files" do
    # generate a test project
    test_project()
    # run our task
    |> Igniter.compose_task("report_studio.gen.report", ["student"])
    # assert the files are created
    |> assert_creates("lib/report_studio_web/controllers/student_report_controller.ex")
    |> assert_creates("lib/report_studio_web/controllers/student_report_html.ex")
    |> assert_creates("lib/report_studio_web/controllers/student_report_html/report.html.heex")
    |> assert_creates("assets/css/student_report.css")
  end
end
