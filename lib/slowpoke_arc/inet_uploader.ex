defmodule SlowpokeArc.InetUploader do
  @moduledoc """
  Manages syncronous uploads to S3.

  Uses:

    - `SlowpokeArc.UploaderSupervisor` Task.Supervisor to manage
      syncronous task supervision;

    - `SlowpokeArc.UploaderStatus` GenServer to manage task status
      accounting.
  """

  alias SlowpokeArc.{Storage, UploaderSupervisor, UploaderStatus}

  @spec put(Storage.file_spec(), Storage.storage(), Storage.storage()) :: {:ok, pid}
  def put(file_spec, local_storage, inet_storage) do
    {definition, version, file_and_scope} = file_spec
    UploaderStatus.add_to_query(file_spec)

    UploaderSupervisor.start_child(fn ->
      {:ok, _file_name} = inet_storage.put(definition, version, file_and_scope)
      UploaderStatus.mark_as_uploaded(file_spec)

      UploaderSupervisor.start_child(fn ->
        local_storage.delete(definition, version, file_and_scope)
      end)
    end)
  end

  @spec delete(Storage.file_spec(), Storage.storage()) :: {:ok, pid}
  def delete({definition, version, file_and_scope}, inet_storage) do
    UploaderSupervisor.start_child(fn ->
      inet_storage.delete(definition, version, file_and_scope)
    end)
  end

  @spec delete_after_uploading(Storage.file_spec(), Storage.storage()) :: :ok
  def delete_after_uploading(file_spec, inet_storage) do
    {definition, version, file_and_scope} = file_spec

    UploaderStatus.do_on_uploaded(file_spec, fn ->
      UploaderSupervisor.start_child(fn ->
        inet_storage.delete(definition, version, file_and_scope)
      end)
    end)
  end
end
