defmodule MyCalendarWeb.TaskDayController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Accounts
  alias MyCalendar.Calendar

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    user_id = Accounts.get_user_id_by_conn(conn)
    task_days = Calendar.list_task_days(user_id)

    conn
    |> put_status(:ok)
    |> render("index.json", task_days: task_days)
  end
end
