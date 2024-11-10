defmodule SportywebWeb.MemberLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Membership
  alias Sportyweb.Membership.Member
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.MemberLive.FormComponent}
        id={@member.id || :new}
        title={@page_title}
        action={@live_action}
        member={@member}
        navigate={if @member.id, do: ~p"/members/#{@member}", else: ~p"/clubs/#{@club}/members"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    member =
      Membership.get_member!(id, [
        :club,
        :emails,
        :financial_data,
        :phones,
        :postal_addresses,
        :notes
      ])

    socket
    |> assign(:page_title, "Kontakt bearbeiten")
    |> assign(:member, member)
    |> assign(:club, member.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Kontakt erstellen")
    |> assign(:member, %Member{
      club_id: club.id,
      club: club,
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      financial_data: [%FinancialData{}],
      notes: [%Note{}]
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    member = Membership.get_member!(id)
    {:ok, _} = Membership.delete_member(member)

    {:noreply,
     socket
     |> put_flash(:info, "Kontakt erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{member.club_id}/members")}
  end
end
