defmodule MyCalendarWeb.CalendarController do
  use MyCalendarWeb, :controller
  alias MyCalendar.Calendar
  import Utilities, only: [sanitize_map: 1]

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    tasks =
      Calendar.show_tasks()
      |> Enum.map(&sanitize_map/1)

    json(conn, tasks)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, task_to_create = %{"date" => _, "label" => _}) do
    task_date = Map.get(task_to_create, "date")

    with {:ok, created_task} <-
           task_to_create
           |> Map.delete("date")
           |> Calendar.add_task(task_date) do
      conn
      |> put_status(200)
      |> json(%{task: sanitize_map(created_task)})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Not a valid task"})
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    with {:ok, deleted_task} <- Calendar.remove_task(id) do
      conn
      |> put_status(200)
      |> json(%{task: sanitize_map(deleted_task)})
    end
  end

  def delete(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Id is missing in parameters"})
  end
end
