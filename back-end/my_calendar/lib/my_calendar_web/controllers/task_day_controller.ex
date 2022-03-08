defmodule MyCalendarWeb.TaskDayController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Calendar

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    task_days = Calendar.list_task_days()
    render(conn, "index.json", task_days: task_days)
  end
end
