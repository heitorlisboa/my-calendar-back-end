defmodule MyCalendar.Calendar.TaskDay do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyCalendar.Calendar.Task

  @fields [:date]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_days" do
    field :date, :date

    has_many :tasks, Task

    timestamps()
  end

  @doc false
  def changeset(task_day, attrs) do
    task_day
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
