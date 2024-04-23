defmodule Cluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cluster.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: Cluster.Worker.start_link(arg)
        # {Cluster.Worker, arg},
      ] ++ children(target())

    spawn(fn -> setup_node() end)

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Cluster.Worker.start_link(arg)
      # {Cluster.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Cluster.Worker.start_link(arg)
      # {Cluster.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:cluster, :target)
  end

  def setup_node do
    # Setting ip node
    list_kind_of_networks = [~c"eth0", ~c"wlan0", ~c"en0"]

    ip = list_kind_of_networks |> get_ip()

    if ip == :undefined do
      {:error,
       "It not posible to identify an ip for the network in the following networks channels: #{Enum.join(list_kind_of_networks, ", ")}"}
    else
      node_name = get_name_node(ip)
      Node.stop()
      System.cmd("epmd", ["-daemon"])
      {status, _} = Node.start(node_name)

      if status == :ok do
        Node.set_cookie(:PLXATUNGSDBIRVZNZSKB)

        spawn(fn ->
          ip_host = System.get_env("IP_HOST", "192.168.0.11")
          _ = Node.connect(:"local@#{ip_host}")
        end)

        _ = Node.list()
        {status, "Node successfully configurated"}
      else
        # Wait until load all system
        Node.stop()
        setup_node()
      end
    end
  end

  def get_name_node(ip) do
    if Cluster.Application.target() == :host do
      :"local@#{ip}"
    else
      :"#{Toolshed.hostname()}@#{ip}"
    end
  end

  def get_ip(list_kind_of_networks, tries \\ 10) do
    network_map = :inet.getifaddrs() |> elem(1) |> Map.new()

    networks_available =
      Enum.filter(list_kind_of_networks, fn k ->
        Cluster.Application.ipv4_addres(network_map, k) != nil
      end)

    if(Enum.count(networks_available) > 0) do
      Cluster.Application.ipv4_addres(network_map, Enum.at(networks_available, 0))
    else
      if tries > 0 do
        Process.sleep(1000)
        get_ip(list_kind_of_networks, tries - 1)
      else
        :undefined
      end
    end
  end

  def ipv4_addres(network_map, id_network) do
    unless Map.has_key?(network_map, id_network) do
      nil
    else
      feature_network = network_map |> Map.get(id_network) |> Keyword.get_values(:addr)
      ip = feature_network |> Enum.find(&match?({_, _, _, _}, &1))
      unless ip == nil, do: ip |> Tuple.to_list() |> Enum.join("."), else: nil
    end
  end
end
