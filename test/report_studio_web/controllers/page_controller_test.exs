defmodule ReportStudioWeb.PageControllerTest do
  use ReportStudioWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end

  test "GET /employee", %{conn: conn} do
    conn = get(conn, ~p"/employee")
    response = html_response(conn, 200)
    assert response =~ "Employee Dossier"
    assert response =~ "Cham Roeun"
    assert response =~ "Dummy Employee 100"
    assert response =~ "/assets/css/employee.css"
  end
end
