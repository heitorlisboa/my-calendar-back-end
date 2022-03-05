defmodule MyCalendar.Calendar do
  alias MyCalendar.Repo
  alias MyCalendar.TaskDay
  alias MyCalendar.Task

  @spec show_tasks :: nil | [%{optional(atom) => any}] | %{optional(atom) => any}
  def show_tasks() do
    Repo.all(TaskDay)
    |> Repo.preload([:tasks])
  end

  @spec add_task_day(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def add_task_day(%{"date" => date}) do
    date = Date.from_iso8601!(date)

    %TaskDay{}
    |> TaskDay.changeset(%{"date" => date})
    |> Repo.insert()
  end

  @spec add_task(map(), String.t()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def add_task(task_to_add, date) do
    with {:ok, task_day} <- get_task_day(date) do
      task_time =
        Map.get(task_to_add, "time")
        |> then(fn time -> if time, do: Time.from_iso8601!(time) end)

      task_to_add =
        task_to_add
        |> Map.put("task_day_id", Map.get(task_day, :id))
        |> Map.replace("time", task_time)

      with {:ok, added_task} <-
             %Task{}
             |> Task.changeset(task_to_add)
             |> Repo.insert() do
        {:ok, Repo.preload(added_task, [:task_day])}
      end
    end
  end

  @spec remove_task(integer()) :: {:ok, struct()} | {:error, String.t()}
  def remove_task(task_id) do
    # TODO: Excluir `task_day` se o mesmo ficar vazio após excluir `task`
    with task when not is_nil(task) <- Repo.get(Task, task_id) do
      Repo.delete(task)
    else
      _ -> {:error, "Task not found"}
    end
  end

  @spec get_task_day(String.t()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  defp get_task_day(date) do
    case Repo.get_by(TaskDay, date: date) do
      nil ->
        with {:ok, _new_task_day} = result <- add_task_day(%{"date" => date}) do
          result
        end

      existing_task_day ->
        {:ok, existing_task_day}
    end
  end
end
