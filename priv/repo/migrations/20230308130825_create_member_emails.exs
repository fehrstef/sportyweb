defmodule Sportyweb.Repo.Migrations.CreateMemberEmails do
  use Ecto.Migration

  def change do
    create table(:member_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :member_id, references(:members, on_delete: :delete_all, type: :binary_id),
        null: false

      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:member_emails, [:member_id])
    create unique_index(:member_emails, [:email_id])
  end
end
