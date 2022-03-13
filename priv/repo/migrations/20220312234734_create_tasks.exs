defmodule MyCalendar.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string, null: false
      add :description, :text
      add :time, :time
      add :task_day_id, references(:task_days, type: :uuid), null: false

      timestamps()
    end
  end
end
