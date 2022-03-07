defmodule MyCalendarWeb.TaskDayController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Calendar
  import Utilities, only: [sanitize_map: 1]

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    tasks =
      Calendar.list_task_days()
      |> Enum.map(&sanitize_map/1)

    json(conn, tasks)
  end
end
