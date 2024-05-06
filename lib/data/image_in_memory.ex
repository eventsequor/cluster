defmodule Data.ImageInMemory do
  use GenServer

  # Client

  def start_link(image, name \\ MyImage) do
    stop(name)
    GenServer.start_link(__MODULE__, image, name: name)
  end

  # Server (callbacks)

  @impl true
  def init(image) do
    {:ok, image}
  end

  @impl true
  def handle_call({:get_pixel, x, y}, _from, image) do
    response = Map.get(image, :pixels) |> Enum.at(x) |> Enum.at(y)
    {:reply, response, image}
  end

  @impl true
  def handle_call({:get_width}, _from, image) do
    response = Map.get(image, :width)
    {:reply, response, image}
  end

  @impl true
  def handle_call({:get_height}, _from, image) do
    response = Map.get(image, :height)
    {:reply, response, image}
  end

  def get_pixel(name_genserver \\ MyImage, x, y) do
    GenServer.call(name_genserver, {:get_pixel, x, y})
  end

  def get_width(name_genserver \\ MyImage) do
    GenServer.call(name_genserver, {:get_width})
  end

  def get_height(name_genserver \\ MyImage) do
    GenServer.call(name_genserver, {:get_height})
  end

  def stop(name_genserver \\ MyImage) do
    unless(GenServer.whereis(name_genserver) == nil) do
      GenServer.stop(name_genserver)
    end
  end
end
