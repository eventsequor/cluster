defmodule Exercises.Task2 do
  alias Cluster.TaskCall

  def rotate(image, angle \\ 0) do
    Data.ImageInMemory.stop()
    name_img_genserver = MyImage

    Enum.map(
      Cluster.LoadBalancer.get_node_lists(),
      fn node ->
        Task.async(fn ->
          TaskCall.run_sync_auto_detect(node, Data.ImageInMemory, :start_link, [
            image,
            name_img_genserver
          ])
        end)
      end
    )
    |> Task.await_many()

    width = Map.get(image, :width)
    height = Map.get(image, :width)

    angle = Math.deg2rad(angle)
    sin = Math.sin(angle)
    cos = Math.cos(angle)
    # point to rotate about
    x0 = 0.5 * (width - 1)
    # center of image
    y0 = 0.5 * (height - 1)

    bitmap =
      Enum.map(
        0..(width - 1),
        fn x ->
          Task.async(fn ->
            TaskCall.run_sync_auto_detect(Exercises.Task2, :get_binary, [
              x,
              x0,
              y0,
              cos,
              sin,
              width,
              height,
              name_img_genserver
            ])
          end)
        end
      )
      |> Task.await_many(60000)
      |> Enum.reduce([], fn pixel, acc -> pixel ++ acc end)
      |> Enum.reverse()

    Pngex.new(
      type: :rgb,
      depth: :depth8,
      width: width,
      height: height
    )
    |> Pngex.generate(bitmap)
  end

  def read(path) do
    {:ok, image} = Imagineer.load(path)
    image
  end

  def write(path, image) do
    File.write(path, image)
  end

  # Benchmark.Performance.average_mili Exercises.Task2, :test_flow, []
  def test_flow(angle \\ 0) do
    root_folder = if target() == :host, do: :code.priv_dir(:cluster), else: "/root/priv"
    origin_image = "#{root_folder}/source_images/logo.png"
    destination_image = "#{root_folder}/output_images/logo.png"
    img = read(origin_image)
    new_image = rotate(img, angle)
    write(destination_image, new_image)
  end

  def get_binary(x, x0, y0, cos, sin, width, height, name_img_genserver) do
    Enum.map(
      0..(height - 1),
      fn y ->
        Task.async(fn ->
          a = x - x0
          b = y - y0
          xx = floor(+a * cos - b * sin + x0)
          yy = floor(+a * sin + b * cos + y0)

          pixel =
            if xx >= 0 and xx < width and yy >= 0 and yy < height do
              Data.ImageInMemory.get_pixel(name_img_genserver, xx, yy)
            else
              Data.ImageInMemory.get_pixel(name_img_genserver, x, y)
            end

          pixel = if pixel == nil, do: [255, 255, 255], else: pixel
          {Kernel.elem(pixel, 0), Kernel.elem(pixel, 1), Kernel.elem(pixel, 2)}
        end)
      end
    )|> Task.await_many(:infinity)
  end

  def target do
    Application.get_env(:cluster, :target)
  end
end
