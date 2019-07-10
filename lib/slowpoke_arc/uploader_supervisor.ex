defmodule SlowpokeArc.UploaderSupervisor do
  @moduledoc """
  Supervises all uploading and deleting tasks.
  """

  def child_spec(user_opts) do
    default_opts = [strategry: :one_for_one, name: __MODULE__]
    opts = Keyword.merge(default_opts, user_opts)

    %{
      id: __MODULE__,
      start: {Task.Supervisor, :start_link, [opts]}
    }
  end

  def start_child(task) do
    Task.Supervisor.start_child(__MODULE__, task)
  end
end
