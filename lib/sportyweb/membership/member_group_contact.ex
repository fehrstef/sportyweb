defmodule Sportyweb.Membership.MemberGroupMember do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Membership.Member
  alias Sportyweb.Membership.MemberGroup

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_group_members" do
    belongs_to :member_group, MemberGroup
    belongs_to :member, Member

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_group_member, attrs) do
    member_group_member
    |> cast(attrs, [:member_group_id, :member_id])
    |> validate_required([:member_group_id, :member_id])
    |> unique_constraint(:member_id, name: "member_group_members_member_id_index")
  end
end
