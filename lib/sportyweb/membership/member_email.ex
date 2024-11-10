defmodule Sportyweb.Membership.MemberEmail do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Membership.Member
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_emails" do
    belongs_to :member, Member
    belongs_to :email, Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_email, attrs) do
    member_email
    |> cast(attrs, [:member_id, :email_id])
    |> validate_required([:member_id, :email_id])
    |> unique_constraint(:email_id, name: "member_emails_email_id_index")
  end
end
