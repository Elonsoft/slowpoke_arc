defmodule SlowpokeArcTest.Mediator do
  @moduledoc false

  use GenServer

  def cast(msg) do
    GenServer.cast(__MODULE__, msg)
  end

  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  def init(receiver) do
    {:ok, receiver}
  end

  def handle_cast(msg, receiver) do
    send(receiver, msg)
    {:noreply, receiver}
  end
end
