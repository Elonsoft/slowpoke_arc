defmodule SlowpokeArcTest.MyStorage do
  use SlowpokeArc,
    local_storage: SlowpokeArcTest.LocalStorage,
    inet_storage: SlowpokeArcTest.InetStorage
end
