defmodule SportywebWeb.MemberLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Membership
  alias Sportyweb.Membership.Member
  alias SportywebWeb.Sorting
  alias SportywebWeb.Filter
  alias Sportyweb.Legal.Contract

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:club_navigation_current_item, :members)
      |> assign(:sorting, %Sorting{})
      |> assign(:filter, %Filter{})
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
    IO.puts("sorting was changed to #{inspect(sorting)}}")
    {:noreply, assign(socket, :sorting, sorting) |> assign_members()}
  end

  @impl true
  def handle_info({SportywebWeb.FilterInputComponent, {:filter_saved, %Filter{} = filter}}, socket) do
    IO.puts("filter was changed to #{inspect(filter)}}")
    {:noreply, assign(socket, :filter, filter) |> assign_members()}
  end


  def assign_members(socket) do
    club_id = socket.assigns.club.id
    sorting = socket.assigns.sorting
    filter = socket.assigns.filter

    mapped_sorting =
     case {sorting.sort_direction, sorting.sorted_attribute } do
       {"asc", "Vorname"} -> [asc: :first_name]
       {"desc", "Vorname"} -> [desc: :first_name]
       {"asc", "Nachname"} -> [asc: :last_name]
       {"desc", "Nachname"} -> [desc: :last_name]
       {"asc", "Geburtsdatum"} -> [asc: :birthday]
       {"desc", "Geburtsdatum"} -> [desc: :birthday]
       {_, _} -> nil
    end

    mapped_filter =
      case {filter.attribute, filter.value} do
        {"Vorname", value} -> [first_name: value]
        {"Nachname", value} -> [last_name: value]
        {"Geburtsdatum", value} -> [birthday: value]
        {_, _} -> nil
      end

    query = %{club_id: club_id,
      order_by: mapped_sorting,
      filter: mapped_filter,
      preloads: [contracts: [:departments, :groups, :fee]]
      }

      IO.inspect(query)
    members = Membership.list_members_by_query(query)
    stream(socket, :members, members, reset: true)
  end

  @impl true
  def handle_event("export", _, socket) do
    IO.puts("export clicked")
    export_list(socket)

#    {:noreply, socket}
  end

  def export_list(socket) do
    club_id = socket.assigns.club.id
    members = Membership.list_members(club_id)

    # export with elixlsx
#    sheet = Elixlsx.Sheet.with_name("Sheet 1")
#            |> Elixlsx.Sheet.set_cell("A1", "Hello", bold: true)
#    Enum.with_index(members, fn m, i ->
#      sheet
#      |> Elixlsx.Sheet.set_cell("A" + (i + 1), m.last_name)
#    end)
#    Elixlsx.Workbook.append_sheet(%Elixlsx.Workbook{}, sheet ) |> Elixlsx.write_to("/tmp/elixlsx.xlsx")

    # export with exceed
    headings = ["Nachname", "Vorname", "Geschlecht", "Status", "Geburtsdatum"];
    rows = Enum.map(members, fn m -> [m.last_name, m.first_name, m.gender, m.state, m.birthday] end)
    worksheet = Exceed.Worksheet.new("Sheet Name", headings, rows)

    workbook =
      Exceed.Workbook.new("Creator Name")
      |> Exceed.Workbook.add_worksheet(worksheet)

    workbook
      |> Exceed.stream!()
       |> Stream.into(File.stream!("/tmp/exceed.xlsx"))
       |> Stream.run()

    send_download(
      socket,
      {:binary, Base.decode64!(workbook)},
      content_type: "application/xlsx",
      filename: "export.xlsx"
    )
  end
end
