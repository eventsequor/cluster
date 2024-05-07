defmodule Exercises.Task3 do
  def beier_neely(img1, img2) do
    width = Map.get(img1, :width)
    heigth = Map.get(img1, :heigth)

    imSize = [width, heigth]

    numMorphedFrames = 1

    # DeltaP and DeltaQ
    d_P = divide_matrix(sustra_matrix(destP(), srcP()), numMorphedFrames + 1)

    d_Q = divide_matrix(sustra_matrix(destQ(), srcQ()), numMorphedFrames + 1)

    Enum.map(0..(numMorphedFrames - 1), fn each_frame ->
      ## Create a image
      interpolatedP = additing_matrix(srcP(), multiply_matrix(d_P, each_frame + 1))
      interpolatedQ = additing_matrix(srcQ(), multiply_matrix(d_Q, each_frame + 1))

      Enum.map(0..(width - 1), fn w ->
        Enum.map(0..(heigth - 1), fn h ->
          pixel = [w, h]
          DSUM1 = [0.0, 0.0]
          DSUM2 = [0.0, 0.0]
          weightsum = 0

          Enum.map(
            0..(Enum.count(srcP()) - 1),
            fn line ->
              P = Enum.at(interpolatedP, line)
              P1 = Enum.at(srcP(), line)
              P2 = Enum.at(destP(), line)
              Q = Enum.at(interpolatedQ, line)
              Q1 = Enum.at(srcQ(), line)
              Q2 = Enum.at(destQ(), line)

              U =((sustra_matrix(pixel, P)))
            end
          )
        end)
      end)
    end)
  end

  def sustra_matrix(matrix_a, matrix_b) do
    Enum.map(0..(Enum.count(matrix_a) - 1), fn row ->
      IO.inspect(Enum.at(matrix_a, row) |> Enum.at(0))
      a = (Enum.at(matrix_a, row) |> Enum.at(0)) - (Enum.at(matrix_b, row) |> Enum.at(0))
      b = (Enum.at(matrix_a, row) |> Enum.at(1)) - (Enum.at(matrix_b, row) |> Enum.at(1))
      [a, b]
    end)
  end

  def additing_matrix(matrix_a, matrix_b) do
    Enum.map(0..(Enum.count(matrix_a) - 1), fn row ->
      IO.inspect(Enum.at(matrix_a, row) |> Enum.at(0))
      a = (Enum.at(matrix_a, row) |> Enum.at(0)) + (Enum.at(matrix_b, row) |> Enum.at(0))
      b = (Enum.at(matrix_a, row) |> Enum.at(1)) + (Enum.at(matrix_b, row) |> Enum.at(1))
      [a, b]
    end)
  end

  def divide_matrix(matrix, scalar) do
    Enum.map(matrix, fn row ->
      a = Enum.at(row, 0) / scalar
      b = Enum.at(row, 1) / scalar
      [a, b]
    end)
  end

  def multiply_matrix(matrix, scalar) do
    Enum.map(matrix, fn row ->
      a = Enum.at(row, 0) * scalar
      b = Enum.at(row, 1) * scalar
      [a, b]
    end)
  end

  def perpendicular([a, b]) do
    [-b, a]
  end

  def a do
    0.2
  end

  def b do
    1.25
  end

  def m do
    0.1
  end

  def srcP do
    [
      [200, 72],
      [94, 142],
      [84, 142],
      [306, 363],
      [100, 145],
      [237, 190],
      [131, 170],
      [304, 307],
      [161, 137],
      [204, 275],
      [207, 180]
    ]
  end

  def srcQ do
    [
      [94, 142],
      [84, 142],
      [306, 363],
      [189, 258],
      [207, 208],
      [205, 207],
      [304, 307],
      [207, 151],
      [204, 275],
      [207, 180],
      [272, 205]
    ]
  end

  def destP do
    [
      [243, 55],
      [91, 158],
      [65, 147],
      [290, 393],
      [90, 140],
      [250, 205],
      [112, 172],
      [300, 327],
      [161, 137],
      [204, 275],
      [207, 180]
    ]
  end

  def destQ do
    [
      [91, 158],
      [65, 147],
      [290, 393],
      [200, 272],
      [208, 215],
      [208, 212],
      [300, 327],
      [225, 172],
      [204, 275],
      [207, 180],
      [272, 205]
    ]
  end
end
