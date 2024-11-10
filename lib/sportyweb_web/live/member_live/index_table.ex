defmodule SportywebWeb.MemberLive.IndexTableComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.CommonHelper

  alias Sportyweb.Membership.Member

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table id="members" rows={@members} row_click={&JS.navigate(~p"/members/#{&1}")}>
        <:col :let={member} label="Name">
          <%= format_string_field(member.name) %>
        </:col>
        <:col :let={member} label="Art">
          <%= get_key_for_value(Member.get_valid_states(), member.state) %>
        </:col>

        <:action :let={member}>
          <.link navigate={~p"/members/#{member}"}>Anzeigen</.link>
        </:action>
      </.table>
    </div>
    """
  end
end
