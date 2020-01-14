defmodule SlowpokeArc.UploaderStatus do
  @moduledoc false
  # Manages task processing accounting.

  use GenServer

  alias __MODULE__, as: State
  alias SlowpokeArc.Storage

  defstruct files: [], callbacks: %{}

  @spec mark_as_uploaded(Storage.file_spec()) :: :ok
  def mark_as_uploaded(file) do
    GenServer.cast(__MODULE__, {:mark_as_uploaded, file})
  end

  @spec add_to_queue(Storage.file_spec()) :: :ok
  def add_to_queue(file) do
    GenServer.cast(__MODULE__, {:add_to_queue, file})
  end

  @spec do_on_uploaded(Storage.file_spec(), (() -> any)) :: :ok
  def do_on_uploaded(file, callback) do
    GenServer.cast(__MODULE__, {:do_on_uploaded, file, callback})
  end

  @spec still_in_progress?(Storage.file_spec()) :: boolean
  def still_in_progress?(file) do
    GenServer.call(__MODULE__, {:still_in_progress_p, file})
  end

  def init(_opts) do
    {:ok, %State{}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def handle_cast({:mark_as_uploaded, file}, state) do
    %State{files: files, callbacks: callbacks} = state
    new_files = Enum.filter(files, &(&1 != file))
    new_callbacks = Map.drop(callbacks, [file])
    execute_callbacks(new_files, callbacks)
    {:noreply, %{state | files: new_files, callbacks: new_callbacks}}
  end

  def handle_cast({:add_to_queue, file}, %State{files: files} = state) do
    {:noreply, %{state | files: [file | files]}}
  end

  def handle_cast({:do_on_uploaded, file, callback}, state) do
    %State{callbacks: callbacks_map} = state

    new_callbacks =
      Map.update(callbacks_map, file, [callback], fn callbacks ->
        [callback | callbacks]
      end)

    {:noreply, %{state | callbacks: new_callbacks}}
  end

  def handle_call({:still_in_progress_p, file}, _from, state) do
    %State{files: files} = state
    {:reply, Enum.member?(files, file), state}
  end

  defp execute_callbacks(files, callbacks_map) do
    uploaded_files = Map.drop(callbacks_map, files)

    callbacks =
      Enum.flat_map(uploaded_files, fn {_, callbacks} ->
        callbacks
      end)

    Enum.each(callbacks, &apply(&1, []))
  end
end
