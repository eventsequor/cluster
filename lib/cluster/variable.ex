defmodule Cluster.Variable do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> {:crypto.hash(:sha, initial_value), initial_value} end,
      name: __MODULE__
    )
  end

  def get_sha do
    resource_id = {User, {:id, 2}}
    lock = Mutex.await(MyMutexConnect, resource_id)
    sha = Agent.get(__MODULE__, fn {sha, _} -> sha end)
    Mutex.release(MyMutexConnect, lock)
    sha
  end

  def get_value do
    resource_id = {User, {:id, 2}}
    lock = Mutex.await(MyMutexConnect, resource_id)
    value = Agent.get(__MODULE__, fn {_, value} -> value end)
    Mutex.release(MyMutexConnect, lock)
    value
  end

  def save_new_value(value) do
    resource_id = {User, {:id, 2}}
    lock = Mutex.await(MyMutexConnect, resource_id)
    result = Agent.update(__MODULE__, fn _ -> {:crypto.hash(:sha, value), value} end)
    Mutex.release(MyMutexConnect, lock)
    result
  end

  def test do
    Enum.each(1..2, fn x ->
      spawn(fn ->
        IO.inspect(get_value())
        IO.inspect(save_new_value(Integer.to_string(x)))
      end)
    end)
  end
end
