defmodule Exercises.Task1 do
  def count(string) when is_bitstring(string) do
    list_of_words =
      string
      |> String.replace(~r"[?:_!@#$%^&*:|,./]", "")
      |> String.replace("\n", " ")
      |> String.downcase()
      |> String.replace("\t", " ")
      |> String.split(" ")
      |> Enum.filter(fn x -> x != "" end)

    list_of_words = duplicate(list_of_words, 10)
    count_l(list_of_words)
  end

  def count_l(list_of_words) when is_list(list_of_words) do
    IO.puts("number of words")
    IO.inspect(Enum.count(list_of_words))

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
