defmodule SlowpokeArc.InetUploader do
  @moduledoc """
  Manages syncronous uploads to S3.
  """

  alias SlowpokeArc.{FileSpec, Storage, UploaderSupervisor, UploaderStatus}

  @spec put(FileSpec.t(), Storage.storage(), Storage.storage()) :: {:ok, pid}
  def put(file_spec, local_storage, inet_storage) do
    {definition, version, file_and_scope} = file_spec
    file_spec_hash = FileSpec.hash(file_spec)
    UploaderStatus.add_to_queue(file_spec_hash)

    UploaderSupervisor.start_child(fn ->
      {:ok, _file_name} = inet_storage.put(definition, version, file_and_scope)
      UploaderStatus.mark_as_uploaded(file_spec_hash)

      UploaderSupervisor.start_child(fn ->
        :ok = local_storage.delete(definition, version, file_and_scope)
      end)
    end)
  end

  @spec delete(FileSpec.t(), Storage.storage()) :: {:ok, pid}
  def delete({definition, version, file_and_scope}, inet_storage) do
    UploaderSupervisor.start_child(fn ->
      :ok = inet_storage.delete(definition, version, file_and_scope)
    end)
  end

  @spec delete_after_uploading(FileSpec.t(), Storage.storage()) :: :ok
  def delete_after_uploading(file_spec, inet_storage) do
    file_spec_hash = FileSpec.hash(file_spec)

    UploaderStatus.do_on_uploaded(file_spec_hash, fn ->
      delete(file_spec, inet_storage)
    end)
  end
end
