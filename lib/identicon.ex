defmodule Identicon do
  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_cells()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(input)
  end

  def save_image(image, input) do
    # write to file
    File.write!("#{input}.png", image)
  end

  def draw_image(image) do
    # get color and pixel map from image
    %Identicon.Image{color: color, pixel_map: pixel_map} = image
    # create 250x250 blank canvas
    image = :egd.create(250, 250)
    # fill color
    fill = :egd.color(color)
    # iterate through each rectangle to be drawn in pixel map
    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    # render image into binary
    :egd.render(image)
  end

  def build_pixel_map(image) do
    # get grid field from image
    %Identicon.Image{grid: grid} = image

    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    # return new struct with pixel map field
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def build_grid(image) do
    # get hex field from image
    %Identicon.Image{hex: hex} = image
    # get hex field, chunk into groups of 3, and mirror each row, and flatten into 1d list
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirrow_row/1)
      |> List.flatten()
      |> Enum.with_index()

    # return new image struct with grid
    %Identicon.Image{image | grid: grid}
  end

  def filter_cells(image) do
    # get grid field from image
    %Identicon.Image{grid: grid} = image
    # filter cells that are even (those to be filled in w/ color)
    grid =
      Enum.filter(grid, fn {code, _index} ->
        rem(code, 2) == 0
      end)

    # return new image struct with filtered grid
    %Identicon.Image{image | grid: grid}
  end

  def mirrow_row(row) do
    # get first two elements of row
    [first, second | _tail] = row
    # mirror this row symmetrical
    row ++ [second, first]
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
