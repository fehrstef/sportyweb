defmodule Sportyweb.Membership.MemberPostalAddress do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Membership.Member
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_postal_addresses" do
    belongs_to :member, Member
    belongs_to :postal_address, PostalAddress

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_postal_address, attrs) do
    member_postal_address
    |> cast(attrs, [:member_id, :postal_address_id])
    |> validate_required([:member_id, :postal_address_id])
    |> unique_constraint(:postal_address_id,
      name: "member_postal_addresses_postal_address_id_index"
    )
  end
end
