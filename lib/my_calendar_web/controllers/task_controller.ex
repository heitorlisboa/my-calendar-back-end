defmodule MyCalendarWeb.TaskController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Accounts
  alias MyCalendar.Calendar
  alias MyCalendar.Calendar.Task

  action_fallback MyCalendarWeb.FallbackController

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"date" => _, "label" => _} = task_to_create) do
    task_date = Map.get(task_to_create, "date")
    user_id = Accounts.get_user_id_by_conn(conn)

    with {:ok, %Task{} = created_task} <-
           task_to_create
           |> Map.delete("date")
           |> Calendar.add_task(task_date, user_id) do
      conn
      |> put_status(:created)
      |> render("show.json", task: created_task)
    end
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "changes" => changes}) do
    user_id = Accounts.get_user_id_by_conn(conn)
    with {:ok, task_to_update} <- Calendar.get_task(id, user_id),
         {:ok, %Task{} = updated_task} <- Calendar.update_task(task_to_update, changes) do
      conn
      |> put_status(:ok)
      |> render("show.json", task: updated_task)
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    user_id = Accounts.get_user_id_by_conn(conn)
    with {:ok, task_to_delete} <- Calendar.get_task(id, user_id),
         {:ok, %Task{} = deleted_task} <- Calendar.remove_task(task_to_delete) do
      conn
      |> put_status(:ok)
      |> render("show.json", task: deleted_task)
    end
  end
end
