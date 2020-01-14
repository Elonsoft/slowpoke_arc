defmodule SlowpokeArc.InetUploader do
  @moduledoc false
  # Manages syncronous uploads to S3.

  require Logger

  alias SlowpokeArc.{FileSpec, Storage, UploaderSupervisor, UploaderStatus}

  # Default restart timeout is 5 mins.
  @timeout 5 * 60 * 1000

  @spec put(FileSpec.t(), Storage.storage(), Storage.storage()) :: {:ok, pid}
  def put(file_spec, local_storage, inet_storage) do
    {definition, version, file_and_scope} = file_spec
    file_spec_hash = FileSpec.hash(file_spec)
    UploaderStatus.add_to_queue(file_spec_hash)

    UploaderSupervisor.start_child(fn ->
      reply = inet_storage.put(definition, version, file_and_scope)
      {:ok, _file_name} = handle_reply(reply)
      UploaderStatus.mark_as_uploaded(file_spec_hash)

      UploaderSupervisor.start_child(fn ->
        reply = local_storage.delete(definition, version, file_and_scope)
        :ok = handle_reply(reply)
      end)
    end)
  end

  @spec delete(FileSpec.t(), Storage.storage()) :: {:ok, pid}
  def delete({definition, version, file_and_scope}, inet_storage) do
    UploaderSupervisor.start_child(fn ->
      reply = inet_storage.delete(definition, version, file_and_scope)
      :ok = handle_reply(reply)
    end)
  end

  @spec delete_after_uploading(FileSpec.t(), Storage.storage()) :: :ok
  def delete_after_uploading(file_spec, inet_storage) do
    file_spec_hash = FileSpec.hash(file_spec)

    UploaderStatus.do_on_uploaded(file_spec_hash, fn ->
      delete(file_spec, inet_storage)
    end)
  end

  defp handle_reply({:ok, _} = reply) do
    reply
  end

  defp handle_reply(:ok) do
    :ok
  end

  defp handle_reply(reply) do
    Logger.error(
      "Image uploading failed with status: " <>
        "#{:io_lib.format('~p', [reply])}. Restarting after #{@timeout} ms..."
    )

    Process.sleep(@timeout)
    reply
  end
end
