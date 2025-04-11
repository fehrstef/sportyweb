defmodule SportywebWeb.RequestLive.Show do
  use SportywebWeb, :live_view


  alias Sportyweb.Cooperation
  alias Sportyweb.Cooperation.Request
  alias Sportyweb.Personal.Membership

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :requests)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    request =
      Cooperation.get_request!(id, [
        :club,
        :department,
        :group,
        membership: [:contact, :club, :department, :group]
      ])

    page_title = get_key_for_value(Request.get_valid_types(), request.type)

    request_description =
      case request.type do
        "membership_application" ->
          "Mitgliedsantrag von #{request.membership.contact.name} in #{Membership.membership_in(request.membership).name} ab dem #{format_date_field_dmy(request.membership.start_date)}"

        "membership_termination" ->
          "Kündigung der Mitgliedschaft von #{request.membership.contact.name} in in #{Membership.membership_in(request.membership).name}"
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title)
     |> assign(:request_description, request_description)
     |> assign(:request, request)}
  end
end
