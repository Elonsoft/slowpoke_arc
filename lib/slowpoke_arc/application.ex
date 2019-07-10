defmodule SlowpokeArc.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(children(), opts())
  end

  defp children do
    [
      {SlowpokeArc.UploaderSupervisor, []},
      {SlowpokeArc.UploaderStatus, []}
    ]
  end

  defp opts do
    [strategy: :one_for_one, name: SlowpokeArc.Supervisor]
  end
end
