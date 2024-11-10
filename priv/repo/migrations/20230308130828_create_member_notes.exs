defmodule Sportyweb.Repo.Migrations.CreateMemberNotes do
  use Ecto.Migration

  def change do
    create table(:member_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :member_id, references(:members, on_delete: :delete_all, type: :binary_id),
        null: false

      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:member_notes, [:member_id])
    create unique_index(:member_notes, [:note_id])
  end
end
