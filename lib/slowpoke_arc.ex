defmodule SlowpokeArc do
  @moduledoc """
  Provides a storage module for Arc.

  With this storage method, all images are stored locally first,
  then are queued to be uploaded to AWS, and after uploading is
  done, the local copy is deleted. Either an uploading is in progress
  or is already done, the returned url for the resource is always
  valid.

  ## Examples

  To use it, define your configured module:

      defmodule MyApp.Storage do
        use SlowpokeArc
      end

  and then you can add it to config:

      config :arc, storage: MyApp.Storage

  By default it uses `Arc.Storage.Local` for locally saved files
  and `Arc.Storage.S3` for uploadings, but you can change this
  behavior by providing options when using. The example above is
  equivalent to the following one:

      defmodule MyApp.Storage do
        use SlowpokeArc,
          local_storage: Arc.Storage.Local,
          inet_storage: Arc.Storage.S3
      end

  All configuration needed for storage modules is provided
  separately:

      config :arc,
        storage: MyApp.Storage,
        storage_dir: "/pictures_with_cats",
        bucket: "<your-bucket-name>",
        virtual_host: true

      config :ex_aws,
        access_key_id: ["<your-key-id>", :instance_role],
        secret_access_key: ["<your-secret-key>", :instance_role],
        region: "<your-region>"
  """

  defmacro __using__(opts) do
    local_storage = opts[:local_storage] || Arc.Storage.Local
    inet_storage = opts[:inet_storage] || Arc.Storage.S3

    quote do
      @local_storage unquote(local_storage)
      @inet_storage unquote(inet_storage)

      def put(definition, version, file_and_scope) do
        file_spec = {definition, version, file_and_scope}
        SlowpokeArc.Storage.do_put(file_spec, @local_storage, @inet_storage)
      end

      def url(definition, version, file_and_scope, opts \\ []) do
        file_spec = {definition, version, file_and_scope}
        SlowpokeArc.Storage.do_url(file_spec, @local_storage, @inet_storage, opts)
      end

      def delete(definition, version, file_and_scope) do
        file_spec = {definition, version, file_and_scope}
        SlowpokeArc.Storage.do_delete(file_spec, @local_storage, @inet_storage)
      end
    end
  end
end
