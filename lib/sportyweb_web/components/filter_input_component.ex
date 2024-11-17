defmodule SportywebWeb.FilterInputComponent do
  use SportywebWeb, :live_component

  alias SportywebWeb.Filter

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="filter-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
      <.input_grids>
          <.input_grid>
            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:attribute]}
              type="select"
              options={@filter_attributes}
              label="Attribut" />
            </div>
            <div class="col-span-12 md:col-span-2">
              <.input field={@form[:operator]}
                type="select"
                options={["Gleich": "==", "Ungleich": "!="]}
                label="Operator"
              />
            </div>
            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:value]}
              type="text"
              label="Inhalt" />
            </div>
            <div class="col-span-12 md:col-span-1 flex justify-end" style="align-items:flex-end">
              <.button>
                  Filtern
              </.button>

            </div>
            <div class="col-span-12 md:col-span-1 flex justify-end" style="align-items:flex-end" phx-target={@myself} phx-click="reset_filter">
             <.button type="button"><.icon name="hero-x-mark"/></.button>
            </div>
          </.input_grid>
        </.input_grids>
      </.simple_form>

    </div>
    """
  end


  @impl true
  def update(assigns, socket) do
    changeset = write_to_changeset()
    {:ok, socket
          |> assign(assigns)
          |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"filter" => filter_params}, socket) do
    changeset = write_to_changeset(filter_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("reset_filter", params, socket) do
    notify_parent({:filter_saved, %Filter{}})
    {:noreply, socket}
  end



  @impl true
  def handle_event("save", %{"filter" => filter_params}, socket) do
    filter = create_filter(filter_params)

    case filter do
      {:ok, filter} ->
        notify_parent({:filter_saved, filter})
        {:noreply, socket |> writeMessage("Filter updated successfully")}

      {:error, _} ->
        {:noreply, socket|> writeMessage("Filter was not valid")}

    end
  end

  def writeMessage(socket, message) do
    IO.puts(message)
    socket |> put_flash(:info, message)
  end


  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp write_to_changeset(attrs \\ %{}) do
    types = %{operator: :string, attribute: :string, value: :string}
    {%Filter{}, types}
    |> Ecto.Changeset.cast(attrs, Map.keys(types))
    |> Ecto.Changeset.validate_required([:operator, :attribute, :value])
    |> Ecto.Changeset.validate_inclusion(:operator, Filter.get_valid_operators() )
  end

  defp create_filter(attrs \\ %{}) do
    write_to_changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
