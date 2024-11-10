defmodule Sportyweb.Repo.Migrations.CreateMemberPostalAddresses do
  use Ecto.Migration

  def change do
    create table(:member_postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :member_id, references(:members, on_delete: :delete_all, type: :binary_id),
        null: false

      add :postal_address_id,
          references(:postal_addresses, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:member_postal_addresses, [:member_id])
    create unique_index(:member_postal_addresses, [:postal_address_id])
  end
end
