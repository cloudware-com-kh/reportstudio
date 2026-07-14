defmodule ReportStudioWeb.PageController do
  use ReportStudioWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def employee(conn, _params) do
    assigns = %{
      employees: [
        %{name: "Cham Roeun"},
        %{name: "John Doe"}
      ]
    }

    render_report(conn, :employee, assigns)
  end

  # Render the employee preview PDF
  def employee_preview(conn, _params) do
    assigns = %{
      employees: [
        %{name: "Cham Roeun"},
        %{name: "John Doe"}
      ]
    }

    template = ReportStudioWeb.PageHTML.employee(assigns)

    result = ReportStudio.PDFGenerator.generate_pdf(template, "css/employee.css")
    ReportStudio.PDFGenerator.send_inline_pdf(conn, result, "report.pdf")
  end
end
