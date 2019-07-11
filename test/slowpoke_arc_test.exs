defmodule SlowpokeArcTest do
  use ExUnit.Case

  alias SlowpokeArcTest.{Mediator, MyImage, ImageWithBrokenInetStorage}

  test "correctly performs uploading" do
    Mediator.start_link(self())
    assert {:ok, "pushka.png"} = MyImage.store({"test/support/pushka.png", :original})
    assert_receive {:put_local, _}
    [{first, _}, {second, _}] = [just_receive(), just_receive()]
    assert :put_inet = first
    assert :delete_local = second
    Mediator.stop()
  end

  test "deletes local copy after uploading if invoked in progress" do
    Mediator.start_link(self())
    assert {:ok, "pushka.png"} = MyImage.store({"test/support/pushka.png", :original})
    assert :ok = MyImage.delete({"test/support/pushka.png", :original})
    assert_receive {:put_local, _}
    [{first, _}, {second, _}, {third, _}] = [just_receive(), just_receive(), just_receive()]
    assert :put_inet = first
    assert :delete_local = second
    assert :delete_inet = third
    Mediator.stop()
  end

  test "returns local url if inet upoading failed" do
    Mediator.start_link(self())

    assert {:ok, "pushka.png" = file_name} =
             ImageWithBrokenInetStorage.store({"test/support/pushka.png", :oiginal})

    assert_receive {:put_local, _}
    refute_receive {:put_inet, _}
    assert "file:///pushka.png" = ImageWithBrokenInetStorage.url({file_name, :original})
    Mediator.stop()
  end

  defp just_receive do
    receive do
      x -> x
    end
  end
end
