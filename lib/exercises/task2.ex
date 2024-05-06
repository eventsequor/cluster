defmodule Exercises.Task2 do
  alias Cluster.TaskCall

  def rotate(name_img_genserver \\ MyImage, angle \\ 90) do
    IO.puts("Starting rotation")
    width = Data.ImageInMemory.get_width(name_img_genserver)
    height = Data.ImageInMemory.get_height(name_img_genserver)

    angle = Math.deg2rad(angle)
    sin = Math.sin(angle)
    cos = Math.cos(angle)
    # point to rotate about
    x0 = 0.5 * (width - 1)
    # center of image
    y0 = 0.5 * (height - 1)

    num_chucks = floor(height / Enum.count(Cluster.LoadBalancer.get_node_lists()))

    chucks = Enum.to_list(0..(height - 1)) |> Enum.chunk_every(num_chucks)

    """
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
          |> Task.await_many(900_000)
          |> Enum.reduce([], fn pixel, acc -> pixel ++ acc end)
          |> Enum.reverse()
    """

    bitmap =
      Enum.map(0..(height - 1), fn y ->
        Enum.map(0..(width - 1), fn x ->
          a = x - x0
          b = y - y0
          xx = floor(+a * cos - b * sin + x0)
          yy = floor(+a * sin + b * cos + y0)

          pixel =
            if xx >= 0 and xx < width and yy >= 0 and yy < height do
              Data.ImageInMemory.get_pixel(name_img_genserver, xx, yy)
            else
              {255, 255, 255}
            end

          {Kernel.elem(pixel, 0), Kernel.elem(pixel, 1), Kernel.elem(pixel, 2)}
        end)
      end)

    img = Data.ImageInMemory.get_image()

    %Imagineer.Image.PNG{
      alias: Map.get(img, :alias),
      width: Map.get(img, :width),
      height: Map.get(img, :height),
      bit_depth: Map.get(img, :bit_depth),
      color_type: Map.get(img, :color_type),
      color_format: Map.get(img, :color_format),
      uri: Map.get(img, :uri),
      format: Map.get(img, :format),
      attributes: Map.get(img, :attributes),
      data_content: Map.get(img, :data_content),
      raw: Map.get(img, :raw),
      comment: Map.get(img, :comment),
      mask: Map.get(img, :mask),
      compression: Map.get(img, :compression),
      decompressed_data: Map.get(img, :decompressed_data),
      unfiltered_rows: Map.get(img, :unfiltered_rows),
      scanlines: Map.get(img, :scanlines),
      filter_method: Map.get(img, :filter_method),
      interlace_method: Map.get(img, :interlace_method),
      gamma: Map.get(img, :gamma),
      palette: Map.get(img, :palette),
      pixels: bitmap,
      mime_type: Map.get(img, :mime_type),
      background: Map.get(img, :background),
      transparency: Map.get(img, :transparency)
    }
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
    origin_image = "#{root_folder}/source_images/aqua.png"
    destination_image = "#{root_folder}/output_images/aqua.png"
    img = read(origin_image)
    new_image = rotate(img, angle)
    Imagineer.write(new_image, destination_image)
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
      0..(width - 1),
      fn y ->
        a = x - x0
        b = y - y0
        xx = floor(+a * cos - b * sin + x0)
        yy = floor(+a * sin + b * cos + y0)

        pixel =
          if xx >= 0 and xx < width and yy >= 0 and yy < height do
            Data.ImageInMemory.get_pixel(name_img_genserver, xx, yy)
          else
            {255, 255, 255}
          end

        pixel = if pixel == nil, do: [0, 0, 0], else: pixel
        {Kernel.elem(pixel, 0), Kernel.elem(pixel, 1), Kernel.elem(pixel, 2)}
      end
    )
  end

  def target do
    Application.get_env(:cluster, :target)
  end
end
