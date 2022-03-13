defmodule MyCalendar.Repo.Migrations.CreateTaskDays do
  use Ecto.Migration

  def change do
    create table(:task_days, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date, null: false
      add :user_id, references(:users, type: :uuid), null: false

      timestamps()
    end
  end
end
