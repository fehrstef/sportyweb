defmodule Sportyweb.Membership.MemberGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Membership.Member
  alias Sportyweb.Membership.MemberGroupMember

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_groups" do
    belongs_to :club, Club
    many_to_many :members, Member, join_through: MemberGroupMember

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_group, attrs) do
    member_group
    |> cast(attrs, [:club_id])
    |> validate_required([:club_id])
  end
end
