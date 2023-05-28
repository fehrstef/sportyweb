defmodule SportywebWeb.PolymorphicLive.PhonesFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Polymorphic.Phone

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.inputs_for :let={phone} field={@form[:phones]}>
        <.input_grid>
          <div class="col-span-12 md:col-span-8">
            <.input field={phone[:number]} type="text" label="Telefon (optional)" />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input
              field={phone[:type]}
              type="select"
              label="Art"
              options={Phone.get_valid_types}
            />
          </div>
        </.input_grid>
      </.inputs_for>
    </div>
    """
  end
end