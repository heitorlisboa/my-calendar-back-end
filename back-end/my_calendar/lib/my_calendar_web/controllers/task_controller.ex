defmodule MyCalendarWeb.TaskController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Calendar
  alias MyCalendar.Calendar.Task
  import Utilities, only: [sanitize_map: 1]

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"date" => _, "label" => _} = task_to_create) do
    task_date = Map.get(task_to_create, "date")

    with {:ok, %Task{} = created_task} <-
           task_to_create
           |> Map.delete("date")
           |> Calendar.add_task(task_date) do
      conn
      |> put_status(200)
      |> json(%{task: sanitize_map(created_task)})
    end
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "changes" => changes}) do
    task_to_update = Calendar.get_task!(id)

    with {:ok, %Task{} = updated_task} <- Calendar.update_task(task_to_update, changes) do
      conn
      |> put_status(200)
      |> json(%{task: sanitize_map(updated_task)})
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    task_to_delete = Calendar.get_task!(id)

    # TODO: Check if `deleted_task` is the same as `task_to_delete` or it is an
    # empty struct or something else
    with {:ok, %Task{} = deleted_task} <- Calendar.remove_task(task_to_delete) do
      conn
      |> put_status(200)
      |> json(%{task: sanitize_map(deleted_task)})
    end
  end
end
