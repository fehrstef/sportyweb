defmodule Sportyweb.Repo.Migrations.CreateMemberFinancialData do
  use Ecto.Migration

  def change do
    create table(:member_financial_data, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :member_id, references(:members, on_delete: :delete_all, type: :binary_id),
        null: false

      add :financial_data_id,
          references(:financial_data, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:member_financial_data, [:member_id])
    create unique_index(:member_financial_data, [:financial_data_id])
  end
end
