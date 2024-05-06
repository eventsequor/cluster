defmodule Exercises.Task2 do
  alias Cluster.TaskCall

  def rotate(name_img_genserver \\ MyImage, angle \\ 0) do
    width = Data.ImageInMemory.get_width(name_img_genserver)
    height = Data.ImageInMemory.get_height(name_img_genserver)

    angle = Math.deg2rad(angle)
    sin = Math.sin(angle)
    cos = Math.cos(angle)
    # point to rotate about
    x0 = 0.5 * (width - 1)
    # center of image
    y0 = 0.5 * (height - 1)

    num_chucks = floor(width / Enum.count(Cluster.LoadBalancer.get_node_lists()))

    chucks = Enum.to_list(0..(width - 1)) |> Enum.chunk_every(num_chucks)

    bitmap =
      Enum.map(chucks, fn rows_group ->
        Task.async(fn ->
          Cluster.TaskCall.run_sync_auto_detect(Exercises.Task2, :resolve_group_of_pixels, [
            rows_group,
            x0,
            y0,
            cos,
            sin,
            width,
            height,
            name_img_genserver
          ])
        end)
      end)
      |> Task.await_many(120_000)
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

    name_img_genserver
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

  def resolve_group_of_pixels(rows_group, x0, y0, cos, sin, width, height, name_img_genserver) do
    Enum.map(
      rows_group,
      fn x ->
        get_binary(x, x0, y0, cos, sin, width, height, name_img_genserver)
      end
    )
    |> Enum.reduce([], fn pixel, acc -> pixel ++ acc end)
  end

  def get_binary(x, x0, y0, cos, sin, width, height, name_img_genserver) do
    Enum.map(
      0..(height - 1),
      fn y ->
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
      end
    )
  end

  def target do
    Application.get_env(:cluster, :target)
  end
end
