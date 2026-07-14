defmodule ReportStudioWeb.PageController do
  use ReportStudioWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def employee(conn, _params) do
    assigns = %{
      employees: dummy_employees()
    }

    render_report(conn, :employee, assigns)
  end

  # Render the employee preview PDF
  def employee_preview(conn, _params) do
    assigns = %{
      employees: dummy_employees()
    }

    template = ReportStudioWeb.PageHTML.employee(assigns)

    result = ReportStudio.PDFGenerator.generate_pdf(template, "css/employee.css")
    ReportStudio.PDFGenerator.send_inline_pdf(conn, result, "report.pdf")
  end

  defp dummy_employees do
    [
      %{name: "Cham Roeun"},
      %{name: "John Doe"}
      | Enum.map(3..10, fn i -> %{name: "Dummy Employee #{i}"} end)
    ]
  end

  def student(conn, _params) do
    assigns = %{
      students: [
        %{name: "Cham Roeun"},
        %{name: "John Doe"}
      ]
    }

    render_report(conn, :student, assigns)
  end

  def student_preview(conn, _params) do
    assigns = %{
      students: [
        %{name: "Cham Roeun"},
        %{name: "John Doe"}
      ]
    }

    template = ReportStudioWeb.PageHTML.student(assigns)

    result = ReportStudio.PDFGenerator.generate_pdf(template, "css/student.css")
    ReportStudio.PDFGenerator.send_inline_pdf(conn, result, "report.pdf")
  end
end
