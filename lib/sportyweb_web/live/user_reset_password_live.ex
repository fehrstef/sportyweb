defmodule SportywebWeb.UserResetPasswordLive do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header>Passwort ändern</.header>

      <.card class="mt-8">
        <.simple_form
          :let={f}
          for={@changeset}
          id="reset_password_form"
          phx-submit="reset_password"
          phx-change="validate"
        >
          <.error :if={@changeset.action == :insert}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={{f, :password}} type="password" label="Neues Passwort" required />
          <.input
            field={{f, :password_confirmation}}
            type="password"
            label="Neues Passwort bestätigen"
            required
          />
          <:actions>
            <.button phx-disable-with="Resetting...">Passwort ändern</.button>
          </:actions>
        </.simple_form>
      </.card>

      <.live_component
        module={SportywebWeb.UserRegistrationLoginLinksComponent}
        id="user-registration-login-links"
      />
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    socket =
      case socket.assigns do
        %{user: user} ->
          assign(socket, :changeset, Accounts.change_user_password(user))

        _ ->
          socket
      end

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password erfolreich geändert.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Der Link zum Ändern des Passworts ist falsch oder abgelaufen.")
      |> redirect(to: ~p"/")
    end
  end
end
