defmodule MyCalendar.Calendar do
  import Ecto.Query, only: [from: 2]

  alias MyCalendar.Repo
  alias MyCalendar.Calendar.TaskDay
  alias MyCalendar.Calendar.Task

  # TaskDay operations
  @spec list_task_days(binary()) :: nil | [struct()] | struct()
  def list_task_days(user_id) do
    query =
      from td in TaskDay,
        select: td,
        where: td.user_id == ^user_id

    Repo.all(query)
    |> Repo.preload([:tasks])
  end

  @spec get_task_day!(binary()) :: struct()
  defp get_task_day!(id), do: Repo.get!(TaskDay, id)

  @spec create_task_day(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  defp create_task_day(%{"date" => date, "user_id" => user_id}) do
    date = Date.from_iso8601!(date)

    %TaskDay{}
    |> TaskDay.changeset(%{"date" => date, "user_id" => user_id})
    |> Repo.insert()
  end

  @spec get_or_create_task_day(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  defp get_or_create_task_day(%{"date" => date, "user_id" => user_id}) do
    case Repo.get_by(TaskDay, date: date, user_id: user_id) do
      nil ->
        create_task_day(%{"date" => date, "user_id" => user_id})

      existing_task_day ->
        {:ok, existing_task_day}
    end
  end

  @spec remove_task_day(struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  defp remove_task_day(%TaskDay{} = task_day), do: Repo.delete(task_day)

  # Task operations
  @spec get_task(binary(), binary()) :: {:ok, struct()} | {:error, :not_found}
  def get_task(id, user_id) do
    case Repo.get(Task, id) do
      nil ->
        {:error, :not_found}

      task ->
        task_day = get_task_day!(task.task_day_id)

        case task_day.user_id do
          ^user_id -> {:ok, task}
          _ -> {:error, :not_found}
        end
    end
  end

  @spec add_task(map(), String.t(), binary()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def add_task(attrs, date, user_id) do
    task_to_add = process_task_time!(attrs)

    with {:ok, task_day} <- get_or_create_task_day(%{"date" => date, "user_id" => user_id}) do
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

    with {:ok, updated_task} <-
           task
           |> Task.changeset(attrs)
           |> Repo.update() do
      {:ok, Repo.preload(updated_task, [:task_day])}
    end
  end

  @spec remove_task(struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def remove_task(%Task{} = task) do
    with {:ok, removed_task} <- Repo.delete(task) do
      task_day =
        get_task_day!(removed_task.task_day_id)
        |> Repo.preload([:tasks])

      if length(task_day.tasks) == 0, do: remove_task_day(task_day)

      {:ok, Repo.preload(removed_task, [:task_day])}
    end
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
