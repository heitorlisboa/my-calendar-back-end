defmodule MyCalendarWeb.TaskView do
  use MyCalendarWeb, :view

  def render("show.json", %{task: task}) do
    render_one(task, __MODULE__, "task.json")
  end

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      label: task.label,
      description: task.description,
      time: task.time
    }
  end
end
