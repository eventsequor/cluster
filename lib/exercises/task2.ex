defmodule Exercises.Task2 do
  alias ElixirSense.Core.Bitstring
  alias Vix.Vips.Operation
  alias Vix.Vips
  alias Vix.Vips.Image, as: Image2

  @spec rotate() :: none()
  def rotate(angle \\ 0) do
    bin = File.read!("./data/source_images/nevado.jpg")
    {_, %Image2{} = img} = Image2.new_from_buffer(bin)
    Vix.Vips.Image.new_from_binary()
    {_, new_image} = Operation.rotate(img, angle, [])
    IO.puts("value of pixel")
    IO.inspect(Image.get_pixel(img, 20, 20))
    Image.write(new_image, get_default_output_image())
  end

  def get_default_image_binary do
    "./data/source_images/nevado.jpg"
  end

  def get_default_output_image do
    "./data/output_images/nevado.jpg"
  end

  def eder do
    bin = File.read!("./data/source_images/logo.png")
    {_, %Image2{} = img} = Image2.new_from_buffer(bin)
    # Create a blank image.

    IO.inspect(Image.bands(img))

    {_, map} = Vix.Vips.Image.to_list(img)

    # Get back a binary
    binary =
      for x <- 0..(Image.width(img) - 1), y <- 0..(Image.height(img) - 1), into: <<>> do
        pixel = Enum.at(map, x) |> Enum.at(y)
        pixel = if pixel == nil, do: [255, 255, 255], else: pixel
        <<Enum.at(pixel, 0), Enum.at(pixel, 1), Enum.at(pixel, 2)>>
      end

    # binary =
    #  for x <- 0..(Image.width(img) - 1),
    #      y <- 0..(Image.height(img) - 1),
    #      into: <<>>,
    #      do: <<Map.get(map, {x, y})>>

    IO.inspect(byte_size(binary))
    IO.inspect(binary)

    {_, img2} = Vix.Vips.Image.new_from_binary(binary, 348, 348, 3, :VIPS_FORMAT_UCHAR)
    Image.write(img2, "./data/output_images/logo2.png")
    binary
  end
end
