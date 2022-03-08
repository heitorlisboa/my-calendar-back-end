defmodule MyCalendarWeb.FallbackController do
  use MyCalendarWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> json(%{error: "Changeset error", changeset: changeset})
  end

  def call(conn, id) when is_nil(id) do
    conn
    |> put_status(400)
    |> json(%{error: "Task with provided ID not found"})
  end
end
