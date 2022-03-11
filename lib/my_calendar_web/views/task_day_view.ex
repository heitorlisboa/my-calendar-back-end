defmodule MyCalendarWeb.TaskDayView do
  use MyCalendarWeb, :view

  alias MyCalendarWeb.TaskView

  def render("index.json", %{task_days: task_days}) do
    render_many(task_days, __MODULE__, "task_day.json")
  end

  def render("task_day.json", %{task_day: task_day}) do
    %{
      id: task_day.id,
      date: task_day.date,
      tasks: render_many(task_day.tasks, TaskView, "task.json")
    }
  end
end
