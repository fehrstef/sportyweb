defmodule Sportyweb.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id)
      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id)
      add :author_user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :author_name, :string, null: false
      add :author_mail, :string
      add :opening_date, :date, null: false
      add :type, :string, null: false
      add :note, :string
      add :membership_id, references(:memberships, on_delete: :delete_all, type: :binary_id)

      add :is_author_confirmed, :boolean, default: false, null: false
      add :confirmation_token, :string
      add :confirmation_date, :date

      add :state, :string
      add :closing_date, :date

      timestamps(type: :utc_datetime)
    end

    create index(:requests, [:club_id])
    create index(:requests, [:department_id])
    create index(:requests, [:group_id])
  end
end
