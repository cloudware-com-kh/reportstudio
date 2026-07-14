defmodule ReportStudioWeb.PageControllerTest do
  use ReportStudioWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end

  test "GET /report", %{conn: conn} do
    conn = get(conn, ~p"/report")
    response = html_response(conn, 200)
    assert response =~ "Student Report"
    assert response =~ "Cham Roeun"
    assert response =~ "/assets/css/report.css"
    refute response =~ "/assets/css/app.css"
  end

  test "GET /student_report", %{conn: conn} do
    conn = get(conn, ~p"/student_report")
    response = html_response(conn, 200)
    assert response =~ "Student Report"
    assert response =~ "Cham Roeun"
    assert response =~ "/assets/css/student_report.css"
    refute response =~ "/assets/css/app.css"
  end
end
