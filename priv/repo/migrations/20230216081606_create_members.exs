defmodule Sportyweb.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :state, :string, null: false
      add :last_name, :string, null: false
      add :first_name, :string, null: false
      add :gender, :string, null: false
      add :birthday, :date, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:members, [:club_id])
  end
end
