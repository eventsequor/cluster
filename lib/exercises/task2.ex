defmodule Exercises.Task2 do
  alias Vix.Vips.Image, as: Image2

  def rotate(angle \\ 0) do
    bin = File.read!("./data/source_images/box.png")
    {_, %Image2{} = img} = Image2.new_from_buffer(bin)

    width = Image.width(img)
    height = Image.height(img)

    angle = Math.deg2rad(angle)
    sin = Math.sin(angle)
    cos = Math.cos(angle)
    # point to rotate about
    x0 = 0.5 * (width - 1)
    # center of image
    y0 = 0.5 * (height - 1)

    {_, map} = Vix.Vips.Image.to_list(img)

    binary =
      Enum.map(
        0..(width - 1),
        fn x ->
          Task.async(fn -> get_binary(x, x0, y0, cos, sin, width, height, map) end)
        end
      )
      |> Task.await_many()
      |> Enum.reduce(<<>>, fn b, acumu -> acumu <> b end)

    {_, img2} = Vix.Vips.Image.new_from_binary(binary, width, height, 3, :VIPS_FORMAT_UCHAR)
    Image.write(img2, "./data/output_images/logo2.png")
  end

  def get_binary(x, x0, y0, cos, sin, width, height, map) do
    Enum.map(
      0..(height - 1),
      fn y ->
        a = x - x0
        b = y - y0
        xx = floor(+a * cos - b * sin + x0)
        yy = floor(+a * sin + b * cos + y0)

        pixel =
          if xx >= 0 and xx < width and yy >= 0 and yy < height do
            Enum.at(map, xx) |> Enum.at(yy)
          else
            Enum.at(map, x) |> Enum.at(y)
          end

        pixel = if pixel == nil, do: [255, 255, 255], else: pixel
        <<Enum.at(pixel, 0), Enum.at(pixel, 1), Enum.at(pixel, 2)>>
      end
    )
    |> Enum.reduce(<<>>, fn b, acumu -> acumu <> b end)
  end
end
