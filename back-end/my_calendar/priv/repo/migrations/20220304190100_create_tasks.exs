defmodule MyCalendar.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :label, :string
      add :description, :text
      add :time, :time
      add :task_day_id, references(:task_days)

      timestamps()
    end
  end
end
