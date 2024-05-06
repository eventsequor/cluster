defmodule Cluster.LoadBalancer do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_node do
    resource_id = {User, {:id, 1}}
    lock = Mutex.await(MyMutexConnect, resource_id, :infinity)
    pos = Agent.get(__MODULE__, fn v -> v end) + 1
    node_list = Node.list() ++ [Node.self()]
    pos = if pos >= Enum.count(node_list), do: 0, else: pos
    Agent.update(__MODULE__, fn _ -> pos end)
    Mutex.release(MyMutexConnect, lock)
    Enum.at(node_list, pos)
  end

  def get_node_lists do
    resource_id = {User, {:id, 1}}
    lock = Mutex.await(MyMutexConnect, resource_id, :infinity)
    node_list = Node.list() ++ [Node.self()]
    Mutex.release(MyMutexConnect, lock)
    node_list
  end
end
