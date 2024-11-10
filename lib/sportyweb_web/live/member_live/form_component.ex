defmodule SportywebWeb.MemberLive.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Membership
  alias Sportyweb.Membership.Member

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
          id="member-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="hidden">
            <input field={@form[:type].value} type="hidden" readonly />
          </div>

          <.input_grids>
            <%= if @step == 1 do %>
              <.input_grid>
                <div class="col-span-12" id="step-1-type">
                  <!-- Don't remove the id of the div, otherwise LiveView doesn't remove the input in step 2. -->
                  <.input
                    field={@form[:type]}
                    type="select"
                    label="Art"
                    options={Member.get_valid_states()}
                  />
                </div>
              </.input_grid>
            <% end %>

            <%= if @step == 2 do %>
              <.input_grid>
                <div class="col-span-12 md:col-span-4">
                  <.input field={@form[:last_name]} type="text" label="Nachname" />
                </div>

                <div class="col-span-12 md:col-span-4">
                  <.input field={@form[:first_name]} type="text" label="Vorname" />
                </div>

                <div class="col-span-12 md:col-span-6">
                  <.input
                    field={@form[:gender]}
                    type="select"
                    label="Geschlecht"
                    options={Member.get_valid_genders()}
                    prompt="Bitte auswählen"
                  />
                </div>

                <div class="col-span-12 md:col-span-6">
                  <.input
                    field={@form[:state]}
                    type="select"
                    label="Status"
                    options={Member.get_valid_states()}
                    prompt="Bitte auswählen"
                  />
                </div>

                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:birthday]} type="date" label="Geburtsdatum" />
                </div>
              </.input_grid>

              <.input_grid class="pt-6">
                <.inputs_for :let={postal_address} field={@form[:postal_addresses]}>
                  <.live_component
                    module={SportywebWeb.PolymorphicLive.PostalAddressesFormComponent}
                    id={"postal_addresses_#{postal_address.index}"}
                    postal_address={postal_address}
                  />
                </.inputs_for>
              </.input_grid>

              <.input_grid class="pt-6">
                <.inputs_for :let={email} field={@form[:emails]}>
                  <.live_component
                    module={SportywebWeb.PolymorphicLive.EmailFormComponent}
                    id={"email_#{email.index}"}
                    email={email}
                  />
                </.inputs_for>

                <.inputs_for :let={phone} field={@form[:phones]}>
                  <.live_component
                    module={SportywebWeb.PolymorphicLive.PhoneFormComponent}
                    id={"phone_#{phone.index}"}
                    phone={phone}
                  />
                </.inputs_for>
              </.input_grid>

              <.input_grid class="pt-6">
                <.inputs_for :let={financial_data} field={@form[:financial_data]}>
                  <.live_component
                    module={SportywebWeb.PolymorphicLive.FinancialDataFormComponent}
                    id={"financial_data_#{financial_data.index}"}
                    financial_data={financial_data}
                  />
                </.inputs_for>
              </.input_grid>

              <.input_grid class="pt-6">
                <div class="col-span-12">
                  <.label>Notizen (optional)</.label>
                  <.inputs_for :let={note} field={@form[:notes]}>
                    <.input field={note[:content]} type="textarea" />
                  </.inputs_for>
                </div>
              </.input_grid>
            <% end %>
          </.input_grids>

          <:actions>
            <div>
              <%= if @step == 1 && @member_type != "" do %>
                <.button
                  id="next-button"
                  type="button"
                  phx-target={@myself}
                  phx-click={JS.push("update_step", value: %{step: 2})}
                >
                  Weiter
                </.button>
              <% end %>

              <%= if @step == 2 do %>
                <.button phx-disable-with="Speichern...">Speichern</.button>
              <% end %>

              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@member.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @member.id})}
              data-confirm="Unwiderruflich löschen?"
            >
              Löschen
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{member: member} = assigns, socket) do
    changeset = Membership.change_member(member)

    step =
      if !is_nil(member.id) ||
           (get_field(changeset, :step) == 1 && get_field(changeset, :type) != "") do
        2
      else
        1
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:step, step)
     |> assign(:member_type, member.type)
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)}
  end

  @impl true
  def handle_event("validate", %{"member" => member_params}, socket) do
    changeset = Membership.change_member(socket.assigns.member, member_params)

    {:noreply,
     socket
     |> assign(:member_type, get_field(changeset, :type))
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"member" => member_params}, socket) do
    save_member(socket, socket.assigns.action, member_params)
  end

  @impl true
  def handle_event("update_step", %{"step" => step}, socket) do
    {:noreply, assign(socket, :step, step)}
  end

  defp save_member(socket, :edit, member_params) do
    case Membership.update_member(socket.assigns.member, member_params) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_member(socket, :new, member_params) do
    member_params =
      Enum.into(member_params, %{
        "club_id" => socket.assigns.member.club.id
      })

    case Membership.create_member(member_params) do
      {:ok, _member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
