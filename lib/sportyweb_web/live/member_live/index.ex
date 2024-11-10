defmodule SportywebWeb.MemberLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Membership.Member
  alias Sportyweb.Legal.Contract

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, members: [contracts: [:departments, :groups, :fee]])

    socket
    |> assign(:page_title, "Kontakte & Mitglieder")
    |> assign(:club, club)
    |> stream(:members, club.members)
  end

  def print_club_fees(%Member{} = member) do
    active_contracts = Member.get_active_membership_contracts(member)
    department_contracts = Enum.filter(active_contracts, fn c -> Contract.is_club_contract(c) end)
    contract_object_names = Enum.map(department_contracts, fn contract -> if contract.fee do contract.fee.name else "" end end)
    Enum.join(contract_object_names, ", ")
  end

  def print_departments(%Member{} = member) do
    active_contracts = Member.get_active_membership_contracts(member)
    department_contracts = Enum.filter(active_contracts, fn c -> Contract.is_department_contract(c) end)
    contract_object_names = Enum.map(department_contracts, fn c -> Contract.get_object(c).name  end)
    Enum.join(contract_object_names, ", ")
  end

  def print_groups(%Member{} = member) do
    active_contracts = Member.get_active_membership_contracts(member)
    group_contracts = Enum.filter(active_contracts, fn c -> Contract.is_group_contract(c) end)
    contract_object_names = Enum.map(group_contracts, fn c -> Contract.get_object(c).name end)
    Enum.join(contract_object_names, ", ")
  end



end
