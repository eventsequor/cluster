defmodule Exercises.Task2 do
  alias Cluster.TaskCall

  def rotate(img, angle \\ 90) do
    {:ok, image} = Imagineer.load("./data/source_images/box.png")

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
          # IO.inspect Enum.at(Map.get(image, :pixels), x)
          Task.async(fn ->
            TaskCall.run_sync_auto_detect(Exercises.Task2, :get_binary, [
              x,
              x0,
              y0,
              cos,
              sin,
              width,
              height,
              Map.get(image, :pixels)
            ])
          end)
        end
      )
      |> Task.await_many()
      |> Enum.reduce([], fn pixel, acc -> pixel ++ acc end)
      |> Enum.reverse()

    IO.inspect(Enum.count(bitmap))

    image =
      Pngex.new(
        type: :rgb,
        depth: :depth8,
        width: width,
        height: height
      )
      |> Pngex.generate(bitmap)

    File.write("gray8_256x256.png", image)
  end

  def read(path) do
    {:ok, image} = Imagineer.load(path)
    image
  end

  def write(path, image) do
    File.write(path, image)
  end

  def test_flow do
    path_image = "./data/source_images/box.png"
    angle = 120
  end

  def get_binary(x, x0, y0, cos, sin, width, height, pixel_map) do
    Enum.map(
      0..(height - 1),
      fn y ->
        a = x - x0
        b = y - y0
        xx = floor(+a * cos - b * sin + x0)
        yy = floor(+a * sin + b * cos + y0)

        pixel =
          if xx >= 0 and xx < width and yy >= 0 and yy < height do
            Enum.at(pixel_map, xx) |> Enum.at(yy)
          else
            Enum.at(pixel_map, x) |> Enum.at(y)
          end

        pixel = if pixel == nil, do: [255, 255, 255], else: pixel
        {Kernel.elem(pixel, 0), Kernel.elem(pixel, 1), Kernel.elem(pixel, 2)}
      end
    )
  end
end
