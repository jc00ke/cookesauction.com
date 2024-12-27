defmodule Mix.Tasks.Images do
  @moduledoc """
  Creates the upload-ready images and directory based
  on a path to a directory of images.
  """
  @shortdoc "Creates images for the site."

  use Mix.Task

  @impl Mix.Task
  def run(argv) do
    {opts, _args, _invalid} =
      OptionParser.parse(argv, strict: [src: :string, dest: :string, start: :integer])

    src = Keyword.fetch!(opts, :src) |> Path.expand()
    dest = Keyword.get_lazy(opts, :dest, fn -> Path.join(src, "upload") end) |> Path.expand()
    start = Keyword.get(opts, :start, 0)

    if !File.dir?(src), do: raise("Source dir #{src} doesn't exist.")
    :ok = File.mkdir_p(dest)

    photos = Path.wildcard("#{src}/*.{jpg,JPG,jpeg,JPEG}")

    Enum.with_index(photos, fn photo, idx ->
      filename = "#{idx + start}"
      original_raw = File.read!(photo)

      {:ok, original} = Image.from_binary(original_raw)
      Image.write(original, Path.join(dest, "#{filename}_original.jpg"))

      {:ok, main_photo} = Image.thumbnail(original, 800, crop: :attention)
      Image.write(main_photo, Path.join(dest, "#{filename}.jpg"))

      {:ok, small_photo} = Image.thumbnail(original, 125, crop: :attention)
      Image.write(small_photo, Path.join(dest, "#{filename}_small.jpg"))
    end)
  end
end
