defmodule Sportyweb.Repo.Migrations.CreateClubNotes do
  use Ecto.Migration

  def change do
    create table(:club_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:club_notes, [:club_id])
    create index(:club_notes, [:note_id])
  end
end
