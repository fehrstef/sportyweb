defmodule Sportyweb.Cooperation.Request do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Group
  alias Sportyweb.Organization.Department
  alias Sportyweb.Personal.Membership
  alias Sportyweb.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "requests" do
    # content describing the request as soon as it is created
    belongs_to :club, Club
    belongs_to :department, Department
    belongs_to :group, Group
    belongs_to :author_user, User
    field :author_name, :string, default: ""
    field :author_mail, :string, default: ""
    field :opening_date, :date
    field :type, :string
    field :note, :string, default: ""
    belongs_to :membership, Membership

    # allowing an automated confirmation of requests from public available pages
    field :is_author_confirmed, :boolean, default: false
    field :confirmation_token, :string, default: nil
    field :confirmation_date, :date, default: nil

    # fields filled when the request is handled
    field :state, :string, default: nil
    field :closing_date, :date

    timestamps(type: :utc_datetime)
  end

  def get_valid_states do
    [
      [key: "Offen", value: "open"],
      [key: "Angenommen", value: "accepted"],
      [key: "Abgelehnt", value: "declined"]
    ]
  end

  def get_valid_types do
    [
      [key: "Mitgliedsantrag", value: "membership_application"],
      [key: "Kündigung der Mitgliedschaft", value: "membership_termination"]
    ]
  end

  def get_addressee(request) do
    IO.inspect(request)
    cond do
      request.group != nil -> request.group
      request.department != nil -> request.department
      true -> request.club
    end
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [
      :club_id,
      :department_id,
      :group_id,
      :author_name,
      :author_user_id,
      :author_mail,
      :opening_date,
      :type,
      :note,
      :membership_id,
      :is_author_confirmed,
      :confirmation_token,
      :confirmation_date,
      :state,
      :closing_date
    ])
    |> validate_required([
      :club_id,
      :author_name,
      :is_author_confirmed,
      :type,
      :opening_date,
      :state
    ])
    |> update_change(:author_name, &String.trim/1)
    |> update_change(:note, &String.trim/1)
    |> validate_length(:author_name, max: 250)
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> validate_inclusion(
      :state,
      get_valid_states() |> Enum.map(fn state -> state[:value] end)
    )
    |> validate_confirmation_token()
    |> validate_closing_state()
    |> validate_attached_membership()
  end

  defp validate_confirmation_token(%Ecto.Changeset{} = changeset) do
    if get_field(changeset, :is_author_confirmed) do
      changeset
    else
      changeset
      |> validate_required(:confirmation_token,
        message: "confirmation_token is required for unconfirmed authors"
      )

      validate_required(:author_mail, message: "author_mail is required for unconfirmed authors")
    end
  end

  defp validate_attached_membership(%Ecto.Changeset{} = changeset) do
    type = get_field(changeset, :type)

    if type == "membership_application" || type == "membership_termination" do
      changeset
      |> validate_required(:membership_id,
        message: "related membership is required for requests of type #{type}"
      )
    else
      changeset
    end
  end

  defp validate_closing_state(%Ecto.Changeset{} = changeset) do
    state = get_field(changeset, :state)

    if state != "open" do
      changeset
      |> validate_required(:closing_date,
        message: "closing_date is required for requests with state #{state}"
      )
    else
      changeset
    end
  end
end
