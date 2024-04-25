defmodule Cluster.Subprocess do
  # Eder
  # This module is peding to develop is a system to chat in a cluster set of rasberry pi
  def receive_message do
    receive do
      {:message, value} -> IO.puts(value)
    end

    receive_message()
  end
end
