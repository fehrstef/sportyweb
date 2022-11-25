defmodule SportywebWeb.UserClubRolesLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user_club_roles, AccessControl.get_user_club_roles!(id))}
  end

  defp page_title(:show), do: "Show User club roles"
  defp page_title(:edit), do: "Edit User club roles"
end
