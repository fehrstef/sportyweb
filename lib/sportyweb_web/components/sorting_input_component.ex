defmodule SportywebWeb.SortingInputComponent do
  use SportywebWeb, :live_component

  alias SportywebWeb.Sorting

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="sorting-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
      <.input_grids>
          <.input_grid>
            <div class="col-span-12 md:col-span-3">
              <.input field={@form[:sort_direction]}
                type="select"
                options={["Aufsteigend": "asc", "Absteigend": "desc"]}
                label="Richtung"
              />
            </div>
            <div class="col-span-12 md:col-span-7">
              <.input field={@form[:sorted_attribute]}
              type="select"
              options={@sorted_by_options}
              label="Sortieren nach" />
            </div>
            <div class="col-span-12 md:col-span-2 flex justify-end" style="align-items:flex-end">
              <.button>Sortieren</.button>
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
  def handle_event("validate", %{"sorting" => sorting_params}, socket) do
    changeset = write_to_changeset(sorting_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"sorting" => sorting_params}, socket) do
    sorting = create_sorting(sorting_params)

    case sorting do
      {:ok, sorting} ->
        notify_parent({:sorting_saved, sorting})
        {:noreply, socket |> writeMessage("Sorting updated successfully")}

      {:error, _} ->
        {:noreply, socket|> writeMessage("Sorting was not valid")}

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
    types = %{sorted_attribute: :string, sort_direction: :string}
    {%Sorting{}, types}
    |> Ecto.Changeset.cast(attrs, Map.keys(types))
    |> Ecto.Changeset.validate_required([:sort_direction, :sorted_attribute])
    |> Ecto.Changeset.validate_inclusion(:sort_direction, Sorting.get_valid_directions() )
  end

  defp create_sorting(attrs \\ %{}) do
    write_to_changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
