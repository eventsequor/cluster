defmodule Exercises.Task3 do
  def beier_neely(img1, img2) do
    width = Map.get(img1, :width)
    height = Map.get(img1, :height)

    imSize = [width, height]

    numMorphedFrames = 1

    # Constants for line weight equation
    a = 0.2
    b = 1.25
    m = 0.1

    # DeltaP and DeltaQ
    d_P = divide_matrix(sustra_matrix(destP(), srcP()), numMorphedFrames + 1)

    d_Q = divide_matrix(sustra_matrix(destQ(), srcQ()), numMorphedFrames + 1)

    Enum.map(0..(numMorphedFrames - 1), fn each_frame ->
      ## Create a image
      interpolatedP = additing_matrix(srcP(), multiply_matrix(d_P, each_frame + 1))
      interpolatedQ = additing_matrix(srcQ(), multiply_matrix(d_Q, each_frame + 1))

      Enum.map(0..(width - 1), fn w ->
        Enum.map(0..(height - 1), fn h ->
          pixel = [w, h]
          dSUM1 = [0.0, 0.0]
          dSUM2 = [0.0, 0.0]
          weightsum = 0

          srcP_length = Enum.count(srcP()) - 1

          Enum.map(
            0..srcP_length,
            fn line ->
              vP = Enum.at(interpolatedP, line)
              vP1 = Enum.at(srcP(), line)
              vP2 = Enum.at(destP(), line)
              vQ = Enum.at(interpolatedQ, line)
              vQ1 = Enum.at(srcQ(), line)
              vQ2 = Enum.at(destQ(), line)

              pU0 = dot(sustra_matrix(pixel, vP), sustra_matrix(vQ, vP))

              pU1 =
                vectorial_norm(sustra_matrix(vQ, vP)) *
                  vectorial_norm(sustra_matrix(vQ, vP))

              pU = pU0 / pU1

              pV0 =
                dot(
                  sustra_matrix(pixel, vP),
                  perpendicular(sustra_matrix(vQ, vP))
                )

              pV1 = vectorial_norm(sustra_matrix(vQ, vP))
              pV = pV0 / pV1

              xPrime1_0 =
                additing_matrix(vP1, multiply_matrix(sustra_matrix(vQ1, vP1), pU))

              xPrime1_1 =
                multiply_matrix(perpendicular(sustra_matrix(vQ1, vP1)), pV)

              xPrime1_2 = vectorial_norm(sustra_matrix(vQ1, vP1))

              xPrime1 =
                additing_matrix(xPrime1_0, divide_matrix(xPrime1_1, xPrime1_2))

              ###################
              xPrime2_0 =
                additing_matrix(vP2, multiply_matrix(sustra_matrix(vQ2, vP2), pU))

              xPrime2_1 =
                multiply_matrix(perpendicular(sustra_matrix(vQ2, vP2)), pV)

              xPrime2_2 = vectorial_norm(sustra_matrix(vQ2, vP2))

              xPrime2 =
                additing_matrix(xPrime2_0, divide_matrix(xPrime2_1, xPrime2_2))

              displacement1 = sustra_matrix(xPrime1, pixel)
              displacement2 = sustra_matrix(xPrime2, pixel)

              # get shortest distance from P to Q
              shortestDist =
                cond do
                  pU >= 1 -> vectorial_norm(sustra_matrix(vQ, pixel))
                  pU <= 0 -> vectorial_norm(sustra_matrix(vP, pixel))
                  pU < 1 && pU > 0 -> Kernel.abs(pV)
                end

              lineWeight = (vectorial_norm(sustra_matrix(vP, vQ)) ** m / (a + shortestDist)) ** b

              dSUM1 =
                additing_matrix(
                  dSUM1,
                  additing_matrix(dSUM1, multiply_matrix(displacement1, lineWeight))
                )

              dSUM2 =
                additing_matrix(
                  dSUM2,
                  additing_matrix(dSUM2, multiply_matrix(displacement2, lineWeight))
                )

              weightsum = weightsum + lineWeight
            end
          )


          IO.inspect(dSUM1)
          IO.inspect(dSUM2)
          IO.inspect(weightsum)
          if h<2, do: 1 / 0
        end)

        w
      end)

      each_frame
    end)
  end

  def vectorial_norm(vector) do
    Enum.reduce(vector, 0, fn x, acu -> x * x + acu end) |> Math.sqrt()
  end

  def dot(matri_a, matrix_b) do
    Enum.at(matri_a, 0) * Enum.at(matrix_b, 0) + Enum.at(matri_a, 1) * Enum.at(matrix_b, 1)
  end

  def sustra_matrix(matrix_a, matrix_b) when is_list(matrix_a) and is_list(matrix_b) do
    boolean = is_list(Enum.at(matrix_a, 0))
    matrix_a = if is_list(Enum.at(matrix_a, 0)), do: matrix_a, else: [matrix_a]
    matrix_b = if is_list(Enum.at(matrix_b, 0)), do: matrix_b, else: [matrix_b]

    result =
      Enum.map(0..(Enum.count(matrix_a) - 1), fn row ->
        a = (Enum.at(matrix_a, row) |> Enum.at(0)) - (Enum.at(matrix_b, row) |> Enum.at(0))
        b = (Enum.at(matrix_a, row) |> Enum.at(1)) - (Enum.at(matrix_b, row) |> Enum.at(1))
        [a, b]
      end)

    if boolean, do: result, else: List.first(result)
  end

  def additing_matrix(matrix_a, matrix_b) do
    boolean = is_list(Enum.at(matrix_a, 0))
    matrix_a = if is_list(Enum.at(matrix_a, 0)), do: matrix_a, else: [matrix_a]
    matrix_b = if is_list(Enum.at(matrix_b, 0)), do: matrix_b, else: [matrix_b]

    result =
      Enum.map(0..(Enum.count(matrix_a) - 1), fn row ->
        a = (Enum.at(matrix_a, row) |> Enum.at(0)) + (Enum.at(matrix_b, row) |> Enum.at(0))
        b = (Enum.at(matrix_a, row) |> Enum.at(1)) + (Enum.at(matrix_b, row) |> Enum.at(1))
        [a, b]
      end)

    if boolean, do: result, else: List.first(result)
  end

  def divide_matrix(matrix, scalar) do
    boolean = is_list(Enum.at(matrix, 0))
    matrix = if is_list(Enum.at(matrix, 0)), do: matrix, else: [matrix]

    result =
      Enum.map(matrix, fn row ->
        a = Enum.at(row, 0) / scalar
        b = Enum.at(row, 1) / scalar
        [a, b]
      end)

    if boolean, do: result, else: List.first(result)
  end

  def multiply_matrix(matrix, scalar) do
    boolean = is_list(Enum.at(matrix, 0))
    matrix = if is_list(Enum.at(matrix, 0)), do: matrix, else: [matrix]

    result =
      Enum.map(matrix, fn row ->
        a = Enum.at(row, 0) * scalar
        b = Enum.at(row, 1) * scalar
        [a, b]
      end)

    if boolean, do: result, else: List.first(result)
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
