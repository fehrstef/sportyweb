defmodule Sportyweb.AccessControl.ApplicationRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "applicationroles" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(application_role, attrs) do
    application_role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
