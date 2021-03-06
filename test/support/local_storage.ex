defmodule SlowpokeArcTest.LocalStorage do
  @moduledoc false

  alias SlowpokeArcTest.Mediator

  def put(definition, version, {file, _} = file_and_scope) do
    Mediator.cast({:put_local, {definition, version, file_and_scope}})
    {:ok, file.file_name}
  end

  def url(definition, version, {file, _} = file_and_scope, options \\ []) do
    Mediator.cast({:url_local, {definition, version, file_and_scope}, options})
    "file:///" <> file.file_name
  end

  def delete(definition, version, file_and_scope) do
    Mediator.cast({:delete_local, {definition, version, file_and_scope}})
    :ok
  end
end
