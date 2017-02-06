defmodule Matrix do

  alias Matrix

  def replace_at(matrix, n, m, new_value) do
    new_row = Enum.at(matrix, n) |>
              List.replace_at(m, new_value)

    List.replace_at(matrix, n, new_row)
  end


  def get_at(matrix, n, m) do
    Enum.at(matrix, n) |> Enum.at(m)
  end


  def transposer(old_matrix, new_matrix, {new_height, new_width}, {idx1, idx2}) do

    cond do
      idx2 >= new_height - 1 and idx1 >= new_width ->
        new_matrix

      idx2 <= new_height ->
        target_value = get_at(old_matrix, idx1, idx2)
        new_matrix   = replace_at(new_matrix, idx2, idx1, target_value)

        if idx1 == new_width - 1 and idx2 < new_height - 1 do
          transposer(old_matrix, new_matrix, {new_height, new_width}, {0, idx2 + 1})
        else
          transposer(old_matrix, new_matrix, {new_height, new_width}, {idx1 + 1, idx2})
        end

      true ->
        new_matrix
    end
  end


  def transpose(n_by_m) do
   
    n_size = Enum.count(n_by_m)
    m_size = Enum.at(n_by_m, 0) |> Enum.count

    # Empty placeholder matrix n by m -> m by n
    new_matrix = List.duplicate(List.duplicate(nil, n_size), m_size)

    transposer(n_by_m, new_matrix, {m_size, n_size}, {0, 0})
  end


  def test do
    a = [
      [:line1col1, :line1col2],
      [:line2col1, :line2col2],
      [:line3col1, :line3col2],
      [:line4col1, :line4col2],
      [:line5col1, :line5col2],
      [:line6col1, :line6col2]
    ]
    
    IO.puts "\nTransposing the following Matrix : "
    IO.inspect a
    IO.puts "\nTo: \n"
    IO.inspect transpose(a)

    b = [
      [:line1col1, :line1col2],
      [:line2col1, :line2col2],
      [:line3col1, :line3col2],
    ]

    IO.puts "\nTransposing the following Matrix : "
    IO.inspect b
    IO.puts "\nTo: \n"
    IO.inspect transpose(b)

    c = [
      [:line1col1, :line1col2, :line1col3, :line1col4, :line1col5, :line1col6],
      [:line2col1, :line2col2, :line2col3, :line2col4, :line2col5, :line2col6]
    ]
    
    IO.puts "\nTransposing the following Matrix : "
    IO.inspect c
    IO.puts "\nTo: \n"

    IO.inspect transpose(c)
  end

end
