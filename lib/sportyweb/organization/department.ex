defmodule Sportyweb.Organization.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.DepartmentContract
  alias Sportyweb.Organization.DepartmentEmail
  alias Sportyweb.Organization.DepartmentFee
  alias Sportyweb.Organization.DepartmentNote
  alias Sportyweb.Organization.DepartmentPhone
  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departments" do
    belongs_to :club, Club
    has_many :groups, Group, preload_order: [asc: :name]
    many_to_many :contracts, Contract, join_through: DepartmentContract
    many_to_many :emails, Email, join_through: DepartmentEmail
    many_to_many :fees, Fee, join_through: DepartmentFee
    many_to_many :notes, Note, join_through: DepartmentNote
    many_to_many :phones, Phone, join_through: DepartmentPhone
    # This line has to be below "many_to_many :contracts"!
    has_many :contacts, through: [:contracts, :contact]

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :creation_date, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(
      attrs,
      [
        :club_id,
        :name,
        :reference_number,
        :description,
        :creation_date
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> validate_required([:club_id, :name, :creation_date])
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> unique_constraint(
      :name,
      name: "departments_club_id_name_index",
      message: "Name bereits vergeben!"
    )
  end
end
