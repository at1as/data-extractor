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
    # Ensure matrix is 2D (ex. [1, 2] -> [[1, 2]])
    n_by_m = if Enum.all?(n_by_m, fn(x) -> is_list(x) end), do: n_by_m, else: [n_by_m]

    cond do
      Enum.all?(n_by_m, fn(x) -> x == [] end) ->
        n_by_m

      true ->
        n_size = Enum.count(n_by_m)
        m_size = Enum.at(n_by_m, 0) |> Enum.count

        # Empty placeholder matrix n by m -> m by n
        new_matrix = List.duplicate(List.duplicate(nil, n_size), m_size)

        transposer(n_by_m, new_matrix, {m_size, n_size}, {0, 0})
    end
  end

end
