defmodule Sportyweb.Membership.MemberFinancialData do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Membership.Member
  alias Sportyweb.Polymorphic.FinancialData

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_financial_data" do
    belongs_to :member, Member
    belongs_to :financial_data, FinancialData

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_financial_data, attrs) do
    member_financial_data
    |> cast(attrs, [:member_id, :financial_data_id])
    |> validate_required([:member_id, :financial_data_id])
    |> unique_constraint(:financial_data_id,
      name: "member_financial_data_financial_data_id_index"
    )
  end
end
