defmodule MyCalendar.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Bcrypt.Base

  alias MyCalendar.Calendar.TaskDay

  @fields [:name, :email, :password]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string

    has_many :task_days, TaskDay

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:email)
  end

  def registration_changeset(user, attrs) do
    changeset(user, attrs)
    |> encrypt_and_put_password()
  end

  defp encrypt_and_put_password(user_changeset) do
    with password <- fetch_field!(user_changeset, :password) do
      encrypted_password = hash_password(password, gen_salt())
      put_change(user_changeset, :password, encrypted_password)
    end
  end
end
