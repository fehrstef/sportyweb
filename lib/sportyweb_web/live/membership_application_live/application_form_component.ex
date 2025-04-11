defmodule SportywebWeb.MembershipApplicationLive.ApplicationFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress
  alias Sportyweb.Mailer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="contact-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input_grids>
          <.input_grid>
            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_last_name]} type="text" label="Nachname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_first_name_1]} type="text" label="Vorname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_first_name_2]} type="text" label="2. Vorname (optional)" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input
                field={@form[:person_gender]}
                type="select"
                label="Geschlecht"
                options={Contact.get_valid_genders()}
                prompt="Bitte auswählen"
              />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:person_birthday]} type="date" label="Geburtsdatum" />
            </div>
          </.input_grid>

          <.input_grid class="pt-6">
            <SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render form={@form} />
          </.input_grid>

          <.input_grid class="pt-6">
            <SportywebWeb.PolymorphicLive.EmailsFormComponent.render form={@form} />
          </.input_grid>

          <.input_grid class="pt-6">
            <SportywebWeb.PolymorphicLive.PhonesFormComponent.render form={@form} />
          </.input_grid>

          <.input_grid class="pt-6">
            <SportywebWeb.PolymorphicLive.FinancialDataFormComponent.render form={@form} />
          </.input_grid>

          <.input_grid class="pt-6">
            <div class="col-span-12 md:col-span-6">
              <.label for="start-date-input">Start</.label>
              <.input
                value={@start_date}
                phx-target={@myself}
                phx-change="start-date-changed"
                type="date"
                id="start-date-input"
                name="start-date"
              />
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
    contact = %Contact{
      club_id: club_id,
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      financial_data: [%FinancialData{}],
      notes: [%Note{}]
    }

    changeset = Personal.change_contact(contact)

    socket =
      socket
      |> assign(assigns)
      |> assign(:club_id, club_id)
      |> assign(:club_name, club_name)
      |> assign(:contact, contact)
      |> assign(:start_date, Date.utc_today())
      |> assign_new(:form, fn -> to_form(changeset) end)

    {:ok, socket}
  end

  @impl true
  def handle_event("start-date-changed", %{"start-date" => start_date}, socket) do
    socket = assign(socket, :start_date, start_date)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset = Personal.change_contact(socket.assigns.contact, contact_params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact" => contact_params}, socket) do
    contact_params =
      Enum.into(contact_params, %{
        "club_id" => socket.assigns.contact.club_id
      })

    case Personal.create_contact(contact_params) do
      {:ok, contact} ->
        membership_attrs = %{
          club_id: contact.club_id,
          contact_id: contact.id,
          state: "pending",
          start_date: socket.assigns.start_date
        }

        case Personal.create_membership(membership_attrs) do
          {:ok, _membership} ->
            contact_mail = Contact.get_most_relevant_email(contact).address

            subject = "Mitgliedsantrag in #{socket.assigns.club_name}"

            body = """
              Hallo #{contact.person_first_name_1} #{contact.person_last_name},

              dein Mitgliedsantrag für den Verein #{socket.assigns.club_name} wurde gespeichert.
            """

            Mailer.deliver_system_notification(contact_mail, subject, body)

            {:noreply,
             socket
             |> put_flash(:info, "Antrag wurde erfolgreich angelegt. ")}

          {:error, changeset} ->
            IO.puts("membership not valid")
            IO.inspect(changeset)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("contact not valid")
        IO.inspect(changeset)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
