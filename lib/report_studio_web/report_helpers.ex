defmodule ReportStudioWeb.ReportHelpers do
  @moduledoc """
  Convenience helpers for controllers that render standalone reports.
  """

  import Phoenix.Controller

  @doc """
  Renders a template without the root layout or application layout.
  Useful for standalone report HTML views.
  """
  def render_report(conn, template, assigns \\ []) do
    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> render(template, assigns)
  end
end
