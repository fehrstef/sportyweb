defmodule Sportyweb.Repo.Migrations.CreateMemberGroupMembers do
  use Ecto.Migration

  def change do
    create table(:member_group_members, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :member_group_id,
          references(:member_groups, on_delete: :delete_all, type: :binary_id),
          null: false

      add :member_id, references(:members, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:member_group_members, [:member_group_id])
    create unique_index(:member_group_members, [:member_id])
  end
end
