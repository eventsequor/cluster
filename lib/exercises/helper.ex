defmodule Exercises.Helper do
  def download!(url, overwrite \\ false) do
    save_as = Path.join(System.tmp_dir!(), URI.encode_www_form(url))
    unless File.exists?(save_as) || overwrite, do: Req.get!(url, output: save_as)
    save_as
  end
end
