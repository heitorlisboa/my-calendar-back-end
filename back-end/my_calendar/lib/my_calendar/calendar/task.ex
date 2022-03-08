defmodule MyCalendar.Calendar.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyCalendar.Calendar.TaskDay

  @fields [:label, :description, :time, :task_day_id]

  schema "tasks" do
    field :label, :string
    field :description, :string
    field :time, :time

    belongs_to :task_day, TaskDay

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @fields)
    |> validate_required([:label])
    |> validate_length(:label, max: 50)
    |> validate_length(:description, max: 500)
  end
end
