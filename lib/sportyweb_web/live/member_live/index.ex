defmodule SportywebWeb.MemberLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Membership
  alias Sportyweb.Membership.Member
  alias SportywebWeb.Sorting
  alias Sportyweb.Legal.Contract

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:club_navigation_current_item, :members)
      |> assign(:sorting, %Sorting{sort_direction: "asc", sorted_attribute: "Nachname"})
    }
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
    club = Organization.get_club!(club_id);

    socket
    |> assign(:page_title, "Kontakte & Mitglieder")
    |> assign(:club, club)
    |> assign_members()
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

  @impl true
  def handle_info({SportywebWeb.SortingInputComponent, {:sorting_saved, %Sorting{} = sorting}}, socket) do
    {:noreply, assign(socket, :sorting, sorting) |> assign_members()}
  end

  def assign_members(socket) do
    club_id = socket.assigns.club.id
    sorting = socket.assigns.sorting

    mapped_sorting =
     case {sorting.sort_direction, sorting.sorted_attribute } do
       nil -> nil
       {_, nil} -> nil
       {"asc", "Vorname"} -> [asc: :first_name]
       {"desc", "Vorname"} -> [desc: :first_name]
       {"asc", "Nachname"} -> [asc: :last_name]
       {"desc", "Nachname"} -> [desc: :last_name]
       {"asc", "Geburtsdatum"} -> [asc: :birthday]
       {"desc", "Geburtsdatum"} -> [desc: :birthday]
    end

    query = %{club_id: club_id,
      order_by: mapped_sorting,
      preloads: [contracts: [:departments, :groups, :fee]]
      }

      IO.inspect(query)
    members = Membership.list_members_by_query(query)
    stream(socket, :members, members, reset: true)
  end

end
