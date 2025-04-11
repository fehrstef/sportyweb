defmodule SportywebWeb.MembershipApplicationLive.TerminationFormComponent do
  use SportywebWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="membership-termination-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input_grids>
          <.input_grid>
            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_first_name_1]} type="text" label="Dein Vorname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_last_name]} type="text" label="Dein Nachname" />
            </div>
          </.input_grid>

          <.input_grid class="pt-6">
            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:birthday]} type="date" label="Geburtsdatum des Mitglieds" />
            </div>
            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:email]} type="text" label="E-Mail des Mitglieds" />
            </div>
          </.input_grid>

          <.input_grid class="pt-6">
            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:termination_date]} type="date" label="Kündigung zum" />
            </div>
          </.input_grid>
        </.input_grids>

        <:actions>
          <.button phx-disable-with="Speichern...">Speichern</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{club_id: club_id, club_name: club_name} = assigns, socket) do
    changeset = form_changeset(%{termination_date: Date.utc_today()})

    socket =
      socket
      |> assign(assigns)
      |> assign(:club_id, club_id)
      |> assign(:club_name, club_name)
      |> assign_new(:form, fn -> to_form(changeset, as: :termination_form) end)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"termination_form" => params}, socket) do
    changeset = validate_input(params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate, as: :termination_form))}
  end

  def handle_event("save", %{"termination_form" => params}, socket) do
    changeset = validate_input(params)

    if Enum.empty?(changeset.errors) do
      send_update(SportywebWeb.MembershipApplicationLive,
        id: "application-form",
        value: changeset
      )

      {:noreply, socket}
    else
      IO.inspect(changeset)

      {:noreply,
       assign(socket, form: to_form(changeset, action: :validate, as: :termination_form))}
    end
  end

  defp form_changeset(params) do
    types = %{
      person_last_name: :string,
      person_first_name_1: :string,
      birthday: :date,
      email: :string,
      termination_date: :date
    }

    Ecto.Changeset.cast({%{}, types}, params, Map.keys(types))
  end

  defp validate_input(params) do
    form_changeset(params)
    |> Ecto.Changeset.update_change(:email, &String.trim/1)
    |> Ecto.Changeset.update_change(:email, &String.downcase/1)
    |> Ecto.Changeset.validate_length(:email, max: 250)
    |> Ecto.Changeset.validate_format(:email, ~r/^$|@/)
    |> Ecto.Changeset.update_change(:person_last_name, &String.trim/1)
    |> Ecto.Changeset.validate_length(:person_last_name, max: 100)
    |> Ecto.Changeset.update_change(:person_first_name_1, &String.trim/1)
    |> Ecto.Changeset.validate_length(:person_first_name_1, max: 75)
    |> Ecto.Changeset.validate_required([
      :person_last_name,
      :person_first_name_1,
      :birthday,
      :email,
      :termination_date
    ])
  end
end
