defmodule SlowpokeArc.FileSpec do
  @moduledoc false
  # Provides functions to deel with file_specs.

  # Why not define a type for YOUR struct in YOUR library so
  # OTHERS doesn't have to define it themselves? O_o
  @type arc_file :: %Arc.File{path: binary, file_name: binary, binary: binary}
  @type semi_arc_file :: %{file_name: binary}
  @type t :: {atom, atom, {semi_arc_file, atom}}

  @spec hash(t) :: binary

  def hash({_definition, _version, {%Arc.File{file_name: file_name}, _scope}}) do
    file_name
  end

  def hash({definition, version, file_and_scope}) do
    Arc.Definition.Versioning.resolve_file_name(definition, version, file_and_scope)
  end
end
