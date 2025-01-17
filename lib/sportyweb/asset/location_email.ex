defmodule Sportyweb.Asset.LocationEmail do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "location_emails" do
    belongs_to :location, Location
    belongs_to :email, Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location_email, attrs) do
    location_email
    |> cast(attrs, [:location_id, :email_id])
    |> validate_required([:location_id, :email_id])
    |> unique_constraint(:email_id, name: "location_emails_email_id_index")
  end
end
