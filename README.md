# SlowpokeArc

Provides a storage module for Arc.

With this storage method, all images are stored locally first,
then are queued to be uploaded to AWS, and after uploading is
done, the local copy is deleted. Either an uploading is in progress
or is already done, the returned url for the resource is always
valid.

## Installation

The package can be installed by adding `slowpoke_arc` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {
      :slowpoke_arc,
      git: "https://github.com/Elonsoft/slowpoke_arc",
      commit: "3a5383850ba6e2a5e996eaaa8ab8fc8b79ea2c6e"
    }
  ]
end
```

## Usage

To use it, define your configured module:

```elixir
defmodule MyApp.Storage do
  use SlowpokeArc
end
```

and then you can add it to config:

```elixir
config :arc, storage: MyApp.Storage
```

By default it uses `Arc.Storage.Local` for locally saved files
and `Arc.Storage.S3` for uploadings, but you can change this
behavior by providing options when using. The example above is
equivalent to the following one:

```elixir
defmodule MyApp.Storage do
  use SlowpokeArc,
    local_storage: Arc.Storage.Local,
    inet_storage: Arc.Storage.S3
end
```

All configuration needed for storage modules is provided
separately:

```elixir
config :arc,
  storage: MyApp.Storage,
  storage_dir: "/pictures_with_cats",
  bucket: "<your-bucket-name>",
  virtual_host: true

config :ex_aws,
  access_key_id: ["<your-key-id>", :instance_role],
  secret_access_key: ["<your-secret-key>", :instance_role],
  region: "<your-region>"
```
