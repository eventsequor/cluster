defmodule Exercises.Task1 do
  def count(string) when is_bitstring(string) do
    words_list =
      string
      |> String.replace(~r"[?:_!@#$%^&*:|,./]", "")
      |> String.replace("\n", " ")
      |> String.downcase()
      |> String.replace("\t", " ")
      |> String.split(" ")
      |> Enum.filter(fn x -> x != "" end)

    words_list = duplicate(words_list, 14)
    IO.puts("Number of words #{Integer.to_string(Enum.count(words_list))}")
    # count_l(list_of_words) #only one list

    # Divide the list int two and sub list the same way n times
    # split_in_half_parts(words_list, 0)

    # Split in equals parts
    IO.inspect(split_in_equals_parts(words_list, 12))
  end

  @spec split_in_equals_parts(any()) :: any()
  def split_in_equals_parts(words_list, parts_to_divide \\ 1) do
    parts_to_divide = if parts_to_divide < 1, do: 1, else: parts_to_divide

    sub_list =
      Enum.chunk_every(words_list, Integer.floor_div(Enum.count(words_list), parts_to_divide))

    x =
      Enum.map(sub_list, fn part_of_list -> Task.async(fn -> count_l(part_of_list) end) end)
      |> Task.await_many()

    Enum.reduce(x, Map.new(), fn feature_map, pivot_branch ->
      Map.merge(feature_map, pivot_branch, fn _k, v1, v2 ->
        v1 + v2
      end)
    end)
  end

  def split_in_half_parts(words_list, times \\ 0) do
    if times == 0 do
      count_l(words_list)
    else
      list_of_list =
        Enum.split(words_list, Integer.floor_div(Enum.count(words_list), 2))

      Enum.map(Tuple.to_list(list_of_list), fn list_splited ->
        Task.async(fn -> split_in_half_parts(list_splited, times - 1) end)
      end)
      |> Task.await_many()

      Enum.reduce(list_of_list, Map.new(), fn feature_map, pivot_branch ->
        Map.merge(feature_map, pivot_branch, fn _k, v1, v2 ->
          v1 + v2
        end)
      end)
    end
  end

  def count_l(list_of_words) when is_list(list_of_words) do
    Enum.reduce(list_of_words, Map.new(), fn word, words_map ->
      if Map.get(words_map, word) == nil do
        Map.put(words_map, word, 1)
      else
        Map.put(words_map, word, Map.get(words_map, word) + 1)
      end
    end)
  end

  def duplicate(list_of_words, number_of_times \\ 10) do
    if number_of_times > 0 do
      duplicate(list_of_words ++ list_of_words, number_of_times - 1)
    else
      list_of_words
    end
  end

  def test_t3 do
    total = 10
    map_result = count("This\tis\na test Test 1230 They're They it's the it they're")
    lowercase_map = Map.new(map_result, fn {key, value} -> {String.downcase(key), value} end)

    valid_number =
      []
      |> Kernel.++([lowercase_map["this"] == 1])
      |> Kernel.++([lowercase_map["1230"] == 1])
      |> Kernel.++([lowercase_map["test"] == 2])
      |> Kernel.++([lowercase_map["is"] == 1])
      |> Kernel.++([lowercase_map["they"] == 1])
      |> Kernel.++([lowercase_map["a"] == 1])
      |> Kernel.++([lowercase_map["the"] == 1])
      |> Kernel.++([lowercase_map["it"] == 1])
      |> Kernel.++([lowercase_map["they're"] == 2])
      |> Kernel.++([lowercase_map["it's"] == 1])
      |> Enum.reduce(0, fn x, acc -> if x, do: acc + 1, else: acc end)

    IO.inspect("Task 3: #{valid_number}/#{total} ")
    IO.inspect(lowercase_map)
  end
end
