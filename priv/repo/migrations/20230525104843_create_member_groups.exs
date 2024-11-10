defmodule Sportyweb.Repo.Migrations.CreateMemberGroups do
  use Ecto.Migration

  def change do
    create table(:member_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:member_groups, [:club_id])
  end
end