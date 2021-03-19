defmodule Identicon do
  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
  end

  def build_grid(image) do
    # get hex field from image
    %Identicon.Image{hex: hex} = image
    # chunk image into chunks of 3
    Enum.chunk_every(hex, 3)
  end

  def pick_color(image) do
    # get first three hex codes from image to represent color (r, g, b) by destructuring from hex field
    %Identicon.Image{hex: [r, g, b | _tail]} = image
    # return new struct, with color field with r,g,b tuple
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
    # hash input md5, convert from binary to list of ints
    hex = :crypto.hash(:md5, input) |> :binary.bin_to_list()
    # return new struct, with hex field as list of ints
    %Identicon.Image{hex: hex}
  end
end
