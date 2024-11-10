defmodule Sportyweb.Finance.Forecast do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  schema "forecasts" do
    field :type, :string, default: "member", virtual: true
    field :member_id, :string, default: "", virtual: true
    field :subsidy_id, :string, default: "", virtual: true
    field :current_date, :date, default: Date.utc_today(), virtual: true
    field :start_date, :date, default: nil, virtual: true
    field :end_date, :date, default: nil, virtual: true
  end

  def get_valid_types do
    [
      [key: "Gebühren von Kontakten", value: "member"],
      [key: "Zuschüsse", value: "subsidy"]
    ]
  end

  @doc false
  def changeset(forecast, attrs) do
    forecast
    |> cast(
      attrs,
      [
        :type,
        :member_id,
        :subsidy_id,
        :start_date,
        :end_date
      ],
      empty_values: ["", nil]
    )
    |> validate_required([:type, :start_date, :end_date])
    |> validate_dates_order(
      :current_date,
      :start_date,
      "Startzeitpunkt darf nicht in der Vergangenheit liegen!"
    )
    |> validate_dates_order(
      :start_date,
      :end_date,
      "Muss zeitlich später als oder gleich \"Von\" sein!"
    )
  end
end
