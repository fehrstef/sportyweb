defmodule SportywebWeb.MembershipApplicationLive do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>

    <.card :if={@step == "index"}>
      <.link phx-click="start_application">
        <.button>Mitgliedschaft beantragen</.button>
      </.link>

      <.link phx-click="start_termination">
        <.button>Mitgliedschaft kündigen</.button>
      </.link>
    </.card>

    <.card :if={@step == "application"}>
      <.live_component
        module={SportywebWeb.MembershipApplicationLive.ApplicationFormComponent}
        id="application-form"
        club_id={@club_id}
        club_name={@club_name}
      />
    </.card>

    <.card :if={@step == "termination"}>
      <.live_component
        module={SportywebWeb.MembershipApplicationLive.TerminationFormComponent}
        id="termination-form"
        club_id={@club_id}
        club_name={@club_name}
      />
    </.card>

    <.card :if={@step == "application_checkout"}>
      Der Antrag auf Mitgliedschaft in {@club_name} wurde angelegt.
      Es wurde eine Nachricht an {@email} versendet.
      Erst nach Bestätigung der E-Mail-Adresse wird der Antrag zur Bearbeitung weiter gegeben.
    </.card>

    <.card :if={@step == "termination_checkout"}>
      Der Antrag wurde angelegt.
      Sofern zur eingegebenen E-Mail-Adresse {@email} eine Mitgliedschaft in {@club_name} gefunden wurde,
      wurde an diese eine Nachricht versendet.
      Erst nach Bestätigung der E-Mail-Adresse wird der Antrag zur Bearbeitung weiter gegeben.
    </.card>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, club.name)
    |> assign(:club_id, club.id)
    |> assign(:step, "index")
    |> assign(:club_name, club.name)
  end

  @impl true
  def handle_event("start_application", _, socket) do
    socket = assign(socket, :step, "application")
    {:noreply, socket}
  end

  @impl true
  def handle_event("start_termination", _, socket) do
    socket = assign(socket, :step, "termination")
    {:noreply, socket}
  end

  @impl true
  def handle_event("application_saved", %{"email" => email}, socket) do
    socket =
      assign(socket, :step, "application_checkout")
      |> assign(:email, email)

    {:noreply, socket}
  end

  @impl true
  def handle_event("termination_saved", %{"email" => email}, socket) do
    socket =
      assign(socket, :step, "termination_checkout")
      |> assign(:email, email)

    {:noreply, socket}
  end
end
