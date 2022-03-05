defmodule MyCalendar.Calendar do
  alias MyCalendar.Repo
  alias MyCalendar.TaskDay
  alias MyCalendar.Task

  @spec show_tasks :: nil | [%{optional(atom) => any}] | %{optional(atom) => any}
  def show_tasks() do
    Repo.all(TaskDay)
    |> Repo.preload([:tasks])
  end

  @spec add_task_day(map()) :: struct()
  def add_task_day(%{"date" => date}) do
    date = Date.from_iso8601!(date)

    {:ok, added_task_day} =
      %TaskDay{}
      |> TaskDay.changeset(%{"date" => date})
      |> Repo.insert()

    added_task_day
  end

  @spec add_task(map(), String.t()) :: struct()
  def add_task(task_to_add, date) do
    task_day = Repo.get_by(TaskDay, date: date)

    task_day =
      if !task_day,
        do: add_task_day(%{"date" => date}),
        else: task_day

    task_time =
      Map.get(task_to_add, "time")
      |> then(fn time -> if time, do: Time.from_iso8601!(time) end)

    task_to_add =
      task_to_add
      |> Map.put("task_day_id", Map.get(task_day, :id))
      |> Map.replace("time", task_time)

    %Task{}
    |> Task.changeset(task_to_add)
    |> Repo.insert()
    |> then(fn {:ok, x} -> Repo.preload(x, [:task_day]) end)
  end

  @spec remove_task(integer()) :: {:ok, struct()} | {:error, String.t()}
  def remove_task(task_id) do
    # TODO: Excluir `task_day` se o mesmo ficar vazio após exlcuir `task`
    task = Repo.get(Task, task_id)

    if task do
      Repo.delete(task)
    else
      {:error, "Task not found"}
    end
  end
end
