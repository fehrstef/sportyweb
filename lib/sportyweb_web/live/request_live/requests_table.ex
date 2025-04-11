defmodule SportywebWeb.Request.RequestTable do
  use SportywebWeb, :live_component
  use SportywebWeb.SortAndFilterTableHelper

  import SportywebWeb.CommonHelper

  alias Sportyweb.Cooperation
  alias Sportyweb.Cooperation.Request

  attr :show_quick_filters, :boolean, default: true

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@show_quick_filters} class="pb-4">
        <.input_grids>
          <.input_grid>
            <div class="col-span-5">
              <.input
                name="author-name-filter-input"
                value={@filters["Author"]}
                label="Author"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "Author"})}
              />
            </div>

            <div class="col-span-4">
              <.input
                name="in-filter-input"
                value={@filters["An"]}
                label="An"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "An"})}
              />
            </div>

            <div class="col-span-3">
              <.input
                name="state-options"
                type="select"
                value={@filters["Status"]}
                options={Request.get_valid_states()}
                prompt="-"
                label="Status"
                phx-target={@myself}
                phx-click={JS.push("quick_filter_changed", value: %{column_label: "Status"})}
              />
            </div>
          </.input_grid>
        </.input_grids>
      </div>

      <div class="overflow-auto max-w-full max-h-[550px]">
        <.table
          id="requests"
          filter_sort_target={@myself}
          rows={@streams.elements}
          sorting={@sorting}
          filters={@filters}
          row_click={fn {_id, request} -> JS.navigate(~p"/requests/#{request}") end}
        >
          <:col :let={{_id, request}} label="Art" sortable filterable>
            {get_key_for_value(Request.get_valid_types(), request.type)}
          </:col>
          <:col :let={{_id, request}} label="Author" sortable filterable>
            {format_string_field(request.author_name)}
          </:col>
          <:col :let={{_id, request}} label="An" sortable filterable>
            {format_string_field(Request.get_addressee(request).name)}
          </:col>
          <:col :let={{_id, request}} label="Geöffnet am" sortable>
            {format_date_field_dmy(request.closing_date)}
          </:col>
          <:col :let={{_id, request}} label="Bestätigt" sortable filterable>
            {format_boolean_field(request.is_author_confirmed)}
          </:col>
          <:col :let={{_id, request}} label="Status" sortable filterable>
            {get_key_for_value(Request.get_valid_states(), request.state)}
          </:col>
          <:col :let={{_id, request}} label="Erledigt am" sortable>
            {format_date_field_dmy(request.closing_date)}
          </:col>

          <:action :let={{_id, request}}>
            <.link navigate={~p"/requests/#{request}"}>Antrag ansehen</.link>
          </:action>
        </.table>
      </div>

      <div class="text-zinc-500 ">
        <%= if @all_element_count==0 do %>
          Es wurde keine passende Anträge gefunden
        <% else %>
          Es werden {@shown_element_count} von {@all_element_count} passenden Anträgen angezeigt. Maximal
          <input
            type="number"
            class="rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 border-zinc-300 focus:border-zinc-400"
            value={@max_elements_counts}
            phx-target={@myself}
            phx-keyup={JS.push("max_element_count_changed", value: %{})}
          />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def column_to_database_field(column_name) do
    case column_name do
      "Author" -> :author_name
      "Art" -> :type
      "An" -> nil
      "Geöffnet am" -> :opening_date
      "Bestätigt" -> :is_author_confirmed
      "Status" -> :state
      "Erledigt am" -> :closing_date
    end
  end

  @impl true
  def column_to_getter(column_name) do
    case column_name do
      "Art" ->
        fn r -> r.type end

      "Author" ->
        fn r -> r.author_name end

      "An" ->
        fn r -> Request.get_addressee(r).name end

      "Geöffnet am" ->
        fn r -> format_date_field_dmy(r.opening_date) end

      "Bestätigt" ->
        fn r -> r.is_author_confirmed end

      "Status" ->
        fn r -> get_key_for_value(Request.get_valid_states(), r.state) end

      "Erledigt am" ->
        fn r -> format_date_field_dmy(r.closing_date) end
    end
  end

  @impl true
  def load_data(club_id, database_sorting, database_filters) do
    Cooperation.list_requests(club_id, database_sorting, database_filters, [
      :club,
      :department,
      :group
    ])
  end
end
