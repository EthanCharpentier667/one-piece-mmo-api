defmodule OnePieceMmo.Repo.Migrations.UpdateBountyToBigint do
  use Ecto.Migration

  def change do
    # Update users table bounty to bigint
    alter table(:users) do
      modify :bounty, :bigint, default: 0
    end

    # Update crews table total_bounty to bigint
    alter table(:crews) do
      modify :total_bounty, :bigint, default: 0
    end
  end
end
