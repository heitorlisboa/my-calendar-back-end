defmodule MyCalendar.Calendar do
  alias MyCalendar.Repo
  alias MyCalendar.Calendar.TaskDay
  alias MyCalendar.Calendar.Task

  # TaskDay operations
  @spec list_task_days :: nil | [%{optional(atom()) => any()}] | %{optional(atom()) => any()}
  def list_task_days() do
    Repo.all(TaskDay)
    |> Repo.preload([:tasks])
  end

  @spec create_task_day(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create_task_day(%{"date" => date}) do
    date = Date.from_iso8601!(date)

    %TaskDay{}
    |> TaskDay.changeset(%{"date" => date})
    |> Repo.insert()
  end

  @spec get_or_create_task_day(String.t()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  defp get_or_create_task_day(date) do
    case Repo.get_by(TaskDay, date: date) do
      nil ->
        with {:ok, _new_task_day} = result <- create_task_day(%{"date" => date}) do
          result
        end

      existing_task_day ->
        {:ok, existing_task_day}
    end
  end

  # Task operations
  @spec get_task!(integer()) :: struct()
  def get_task!(id), do: Repo.get!(Task, id)

  @spec add_task(map(), String.t()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def add_task(attrs, date) do
    task_to_add = process_task_time!(attrs)

    with {:ok, task_day} <- get_or_create_task_day(date) do
      task_to_add =
        task_to_add
        |> Map.put("task_day_id", Map.get(task_day, :id))

      with {:ok, added_task} <-
             %Task{}
             |> Task.changeset(task_to_add)
             |> Repo.insert() do
        {:ok, Repo.preload(added_task, [:task_day])}
      end
    end
  end

  @spec update_task(struct(), map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def update_task(%Task{} = task, attrs) do
    attrs =
      attrs
      |> process_task_time!()
      # Deleting the `task_day_id` entry if it exists since I don't want it to
      # be changed directly
      |> Map.delete("task_day_id")

    # TODO: Create advance and delay task system
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @spec remove_task(struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def remove_task(%Task{} = task) do
    # TODO: Delete `task_day` if it remains empty after deleting `task`
    Repo.delete(task)
  end

  @spec process_task_time!(map()) :: map()
  defp process_task_time!(task_attrs) do
    task_attrs
    |> Map.get("time")
    # Note that this function won't raise error when time is nil. It will only
    # raise if time is a string but in an invalid time format
    |> then(fn time -> if not is_nil(time), do: Time.from_iso8601!(time) end)
    # Note that `Map.replace/3` won't add the time if it doesn't already exist
    |> then(&Map.replace(task_attrs, "time", &1))
  end
end
