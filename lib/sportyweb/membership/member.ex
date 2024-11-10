defmodule Sportyweb.Membership.Member do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Membership.Member
  alias Sportyweb.Membership.MemberEmail
  alias Sportyweb.Membership.MemberGroup
  alias Sportyweb.Membership.MemberGroupMember
  alias Sportyweb.Membership.MemberFinancialData
  alias Sportyweb.Membership.MemberNote
  alias Sportyweb.Membership.MemberPhone
  alias Sportyweb.Membership.MemberPostalAddress
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "members" do
    belongs_to :club, Club
    has_many :contracts, Contract
    many_to_many :member_groups, MemberGroup, join_through: MemberGroupMember
    many_to_many :emails, Email, join_through: MemberEmail
    many_to_many :financial_data, FinancialData, join_through: MemberFinancialData
    many_to_many :notes, Note, join_through: MemberNote
    many_to_many :phones, Phone, join_through: MemberPhone
    many_to_many :postal_addresses, PostalAddress, join_through: MemberPostalAddress

    field :last_name, :string, default: ""
    field :first_name, :string, default: ""
    field :gender, :string, default: ""
    field :state, :string, default: ""
    field :birthday, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  def get_valid_states do
    [
      [key: "Beantragt", value: "applied"],
      [key: "Aktiv", value: "active"],
      [key: "Passiv", value: "passive"],
      [key: "Ausgeschieden", value: "quited"]
    ]
  end

  def get_valid_genders do
    [
      [key: "Männlich", value: "male"],
      [key: "Weiblich", value: "female"],
      [key: "Divers", value: "other"],
      [key: "Keine Angabe", value: "no_info"]
    ]
  end

  def age_in_years(%Member{} = member) do
    # Based on: https://stackoverflow.com/a/71043385

    birthday = member.birthday
    today = Date.utc_today()

    years_diff = today.year - birthday.year

    # If today's date in the year is before the member's birthday, substract 1
    if Date.compare(today, %Date{birthday | year: today.year}) == :lt do
      years_diff - 1
    else
      years_diff
    end
  end

  def has_active_membership_contract?(%Member{} = member) do
    Enum.any?(member.contracts, fn contract ->
      Contract.is_in_use?(contract, Date.utc_today())
    end)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(
      attrs,
      [
        :club_id,
        :last_name,
        :first_name,
        :gender,
        :state,
        :birthday
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:member_groups, required: false)
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:financial_data, required: true)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> cast_assoc(:postal_addresses, required: true)
    |> validate_required([:state])
    |> validate_required([:gender])
    |> update_change(:last_name, &String.trim/1)
    |> update_change(:first_name, &String.trim/1)
    |> validate_length(:last_name, max: 100)
    |> validate_length(:first_name, max: 75)
    |> validate_inclusion(
      :state,
      get_valid_states()
      |> Enum.map(fn state -> state[:value] end)
    )
    |> validate_inclusion(
      :gender,
      get_valid_genders() |> Enum.map(fn gender -> gender[:value] end)
    )
  end

end
