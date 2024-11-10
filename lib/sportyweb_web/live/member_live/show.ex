defmodule SportywebWeb.MemberLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Membership
  alias Sportyweb.Membership.Member

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    member =
      Membership.get_member!(id, [
        :club,
        :emails,
        :financial_data,
        :notes,
        :phones,
        :postal_addresses,
        contracts: [:clubs, :departments, :groups, fee: :internal_events]
      ])

    {:noreply,
     socket
     |> assign(:page_title, "Kontakt: #{member.first_name} #{member.last_name}")
     |> assign(:member, member)
     |> assign(:club, member.club)
     |> stream(:contracts, member.contracts)}
  end
end
