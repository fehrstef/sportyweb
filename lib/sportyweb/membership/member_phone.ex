defmodule Sportyweb.Membership.MemberPhone do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Membership.Member
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_phones" do
    belongs_to :member, Member
    belongs_to :phone, Phone

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_phone, attrs) do
    member_phone
    |> cast(attrs, [:member_id, :phone_id])
    |> validate_required([:member_id, :phone_id])
    |> unique_constraint(:phone_id, name: "member_phones_phone_id_index")
  end
end
