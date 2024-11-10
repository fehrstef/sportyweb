defmodule SportywebWeb.ForecastLive.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Finance
  alias Sportyweb.Finance.Forecast
  alias Sportyweb.Membership

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="forecast-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="start"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12">
                <.input
                  field={@form[:type]}
                  type="select"
                  label="Prognose für"
                  options={Forecast.get_valid_types()}
                  phx-target={@myself}
                  phx-change="update_type"
                />
              </div>

              <%= if @type == "member" do %>
                <div class="col-span-12">
                  <.input
                    field={@form[:member_id]}
                    type="select"
                    label="Kontakt"
                    options={@member_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Alle Kontakte"
                  />
                </div>
              <% end %>

              <%= if @type == "subsidy" do %>
                <div class="col-span-12">
                  <.input
                    field={@form[:subsidy_id]}
                    type="select"
                    label="Zuschuss"
                    options={@subsidy_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Alle Zuschüsse"
                  />
                </div>
              <% end %>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:start_date]} type="date" label="Von" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:end_date]} type="date" label="Bis" />
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Erstellen...">Prognose erstellen</.button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{forecast: forecast} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:type, forecast.type)
     |> assign(:member_options, Membership.list_members(assigns.club.id))
     |> assign(:subsidy_options, Finance.list_subsidies(assigns.club.id))
     |> assign_new(:form, fn ->
       to_form(change(forecast))
     end)}
  end

  @impl true
  def handle_event("validate", %{"forecast" => forecast_params}, socket) do
    changeset =
      socket.assigns.forecast
      |> Forecast.changeset(forecast_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("update_type", %{"forecast" => %{"type" => type}}, socket) do
    {:noreply, assign(socket, :type, type)}
  end

  def handle_event("start", %{"forecast" => forecast_params}, socket) do
    changeset =
      socket.assigns.forecast
      |> Forecast.changeset(forecast_params)
      |> Map.put(:action, :validate)

    if changeset.valid? do
      {:noreply, push_navigate(socket, to: get_navigate(socket, changeset))}
    else
      {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_navigate(socket, %Ecto.Changeset{} = changeset) do
    club_id = socket.assigns.club.id
    type = get_field(changeset, :type)
    member_id = get_field(changeset, :member_id)
    subsidy_id = get_field(changeset, :subsidy_id)
    start_date = Date.to_string(get_field(changeset, :start_date))
    end_date = Date.to_string(get_field(changeset, :end_date))

    case type do
      "member" ->
        case member_id do
          nil ->
            ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/member"

          _ ->
            ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/member/#{member_id}"
        end

      "subsidy" ->
        case subsidy_id do
          nil ->
            ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/subsidy"

          _ ->
            ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/subsidy/#{subsidy_id}"
        end
    end
  end
end
