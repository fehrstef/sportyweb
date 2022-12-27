defmodule SportywebWeb.ClubNavigationComponent do
  use SportywebWeb, :live_component

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :default_link_classes, "text-zinc-700 hover:bg-zinc-50 group flex items-center px-3 py-2 text-base lg:text-sm font-medium rounded-md")
    assigns = assign(assigns, :default_icon_classes, "text-zinc-400 group-hover:text-zinc-500 mr-4 h-6 w-6")

    ~H"""
    <nav class="sticky top-10">
      <div class="space-y-1">
        <.link navigate={~p"/clubs/#{@club}"} class={@default_link_classes}>
          <Heroicons.squares_plus class={@default_icon_classes} />
          <span class="truncate">Dashboard</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}"} class={@default_link_classes}>
          <Heroicons.calendar class={@default_icon_classes} />
          <span class="truncate">Kalender</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}"} class={@default_link_classes}>
          <Heroicons.user_group class={@default_icon_classes} />
          <span class="truncate">Mitglieder</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}"} class={@default_link_classes}>
          <Heroicons.banknotes class={@default_icon_classes} />
          <span class="truncate">Gebühren</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}"} class={@default_link_classes}>
          <Heroicons.lock_closed class={@default_icon_classes} />
          <span class="truncate">Nutzer & Rollen</span>
        </.link>
      </div>
    </nav>
    """
  end
end