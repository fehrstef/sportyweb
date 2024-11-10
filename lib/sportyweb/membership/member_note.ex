defmodule Sportyweb.Membership.MemberNote do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Membership.Member
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_notes" do
    belongs_to :member, Member
    belongs_to :note, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_note, attrs) do
    member_note
    |> cast(attrs, [:member_id, :note_id])
    |> validate_required([:member_id, :note_id])
    |> unique_constraint(:note_id, name: "member_notes_note_id_index")
  end
end
