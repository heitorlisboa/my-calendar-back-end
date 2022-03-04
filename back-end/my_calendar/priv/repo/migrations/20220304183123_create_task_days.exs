defmodule MyCalendar.Repo.Migrations.CreateTaskDays do
  use Ecto.Migration

  def change do
    create table(:task_days) do
      add :date, :date

      timestamps()
    end
  end
end
