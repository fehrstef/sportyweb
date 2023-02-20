defmodule SportywebWeb.DepartmentLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:club_navigation_current_item, :structure)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    department = Organization.get_department!(id, [:club, :groups, :notes])

    {:noreply,
     socket
     |> assign(:page_title, "Abteilung: #{department.name}")
     |> assign(:department, department)
     |> assign(:club, department.club)}
  end
end
