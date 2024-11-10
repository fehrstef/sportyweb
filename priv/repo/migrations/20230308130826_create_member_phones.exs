defmodule Sportyweb.Repo.Migrations.CreateMemberPhones do
  use Ecto.Migration

  def change do
    create table(:member_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :member_id, references(:members, on_delete: :delete_all, type: :binary_id),
        null: false

      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:member_phones, [:member_id])
    create unique_index(:member_phones, [:phone_id])
  end
end
