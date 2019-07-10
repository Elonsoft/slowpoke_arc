defmodule SlowpokeArc.Storage do
  @moduledoc """
  The module that's responsible for file uploading.

  Wraps logic behind implementation of Arc.Storage callbacks:
  `put/3`, `url/3` and `delete/3`. You are not supposed to use
  the module directly, use `SlowpokeArc` instead.

  Note: There is no such a behaviour as Arc.Storage, but Arc
  follows it so shall we.
  """

  alias SlowpokeArc.{InetUploader, UploaderStatus}

  # Why not define a type for YOUR struct in YOUR library so
  # OTHERS doesn't have to define it themselves? O_o
  @type arc_file :: %Arc.File{path: binary, file_name: binary, binary: binary}
  @type storage :: atom
  @type file_spec :: {atom, atom, {arc_file, atom}}

  @spec do_put(file_spec, storage, storage) :: {:ok, String.t()}
  def do_put(file_spec, local_storage, inet_storage) do
    {definition, version, {file, scope}} = file_spec
    local_storage.put(definition, version, {file, scope})
    {:ok, _pid} = InetUploader.put(file_spec, local_storage, inet_storage)
    {:ok, file.file_name}
  end

  @spec do_url(file_spec, storage, storage, list) :: String.t()
  def do_url(file_spec, local_storage, inet_storage, options \\ []) do
    {definition, version, file_and_scope} = file_spec

    if UploaderStatus.still_in_progress?(file_spec) do
      local_storage.url(definition, version, file_and_scope, options)
    else
      inet_storage.url(definition, version, file_and_scope, options)
    end
  end

  @spec do_delete(file_spec, storage, storage) :: :ok
  def do_delete(file_spec, _local_storage, inet_storage) do
    if UploaderStatus.still_in_progress?(file_spec) do
      InetUploader.delete_after_uploading(file_spec, inet_storage)
    else
      InetUploader.delete(file_spec, inet_storage)
    end

    :ok
  end
end
