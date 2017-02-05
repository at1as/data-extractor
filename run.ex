require IEx

defmodule DataExtractor do
  
  alias DataExtractor


  def cleanup_str(input_string) do
    String.trim(input_string, "\n") |> String.trim("\n") |> String.trim(" ")
  end

  def get_range(range_str) do
    {from, to} = String.split(range_str, "-")
    Range.new(from, to)
  end

  def two_dimensional_matrix(row, col, matrix) do
    
  end
  

  def get_filepath do
    filepath = IO.gets "\nWhere is your file located?\n"
    filepath = cleanup_str(filepath)

    if file_exists?(filepath) do
      filepath
    else
      IO.puts "File not found."
      get_filepath
    end
  end


  def file_exists?(filepath) do
    File.exists? filepath
  end


  def prompt_for_filetype do
    filetype = IO.gets("""

      What format is the data in?

        (1) Comma-separated Values

              "First,Second,Third"

        (2) Tab-separated Values

              "First  Second  Third"

        (3) Space-separated Values

              "First Second Third"

        (4) Pipe-Separated Values

              "First|Second|Third"
    """)

    stripped_filetype = cleanup_str(filetype)

    case stripped_filetype do
      "1" -> ","
      "2" -> "\t"
      "3" -> " "
      "4" -> "|"
       _  ->
        IO.puts "Please enter a valid option"
        prompt_for_filetype
    end
  end


  def target_columns do
    target = IO.gets("""

      Which columns are you interested in? (treat first column as '1', not '0')

        Example inputs:

          "2"     # => The second column
          "1-5"   # => The first column to the fifth column
          "all"   # => All columns

    """)

    target = cleanup_str(target) |> String.downcase
    
    cond do
      String.match?(target, ~r/[\d]+$/) ->
        target

      String.match?(target, ~r/[0-9]+\-[0-9]+$/) ->
        get_range(target)

      "all" == target ->
        :all

      true ->
        IO.puts "Please enter a valid value"
        target_columns
    end
  end


  def operation_type do
    operation = IO.gets("""
      
      What operation would you like to do?

        Math:

          1) Sum
          2) Subtract
          3) Multiply
          4) Average
          5) Median
          6) Standard Deviation
          7) Max
          8) Min
          9) Random Value

        Exctraction:

          10) Numeric
          11) Non-Numeric
          12) Alpha-Numeric
          13) ASCII
          14) Non-ASCII

    """)

    operation = cleanup_str(operation)
    
    cond do
      String.match?(operation, ~r/[0-9]+$/) and (Tuple.to_list(Integer.parse(operation)) |> Enum.at(0)) in 1..14 ->
        operation
      true ->
        IO.puts "Enter a valid integer value"
        operation_type
    end
  end


  def split_line(line, delimeter) do
    String.split(line, delimeter)
  end


  def columns(line_portions, bounds) do
    cond do
      is_atom(bounds) and bounds == :all ->
        line_portions

      Integer.parse(bounds) != :error ->
        Enum.at(line_portions, Integer.parse(bounds))

      is_bitstring(bounds) and (String.split(bounds, "-") |> Enum.count == 2) ->
        [first, second] = String.split("-", bounds) |>
                          Enum.map(fn x -> Integer.parse(x) end)

        Enum.drop(line_portions, first) |>
        Enum.take(first + second)
      
      true ->
        :error
    end
  end


  def extract_from_line(line, delimeter, column_range) do
    line_segments = split_line(line, delimeter)
    columns(line_segments, column_range)
  end


  def extract_from_file(path, type, columns, operation) do
    {:ok, file} = File.read(path)
    file_lines  = String.split(file, "\n")
                  |> Enum.reject(fn(x) -> x == "" end)
    
    
    matrix = Enum.map(file_lines, fn(x) ->
      extract_from_line(x, type, columns) 
    end)
    
    matrix = Enum.map(matrix, fn(x) -> operation(x, operation) end)
    """
    # transpose matrix
    new_matrix = []
    x = Enum.count(matrix)
    y = Enum.at(matrix, 0) |> Enum.count

    Enum.with_index(matrix, fn(r, idx1) ->
      Enum.with_index(r, fn(c, idx2) ->
        
        

      end)
    end)
    """
    matrix 
  end


  def operation(row, operation) do
    row = Enum.map(row, &Float.parse(&1)) |>
          Enum.map(fn {x, _} -> x end)

    case operation do
      "1"  -> Enum.sum(row)
      "2"  -> Enum.reduce(row, fn x, acc -> acc - x end)
      "3"  -> Enum.reduce(row, fn x, acc -> acc * x end)
      "4"  -> Enum.reduce(row, fn x, acc -> acc + x end) / Enum.count(row)
      "5"  -> row #MEDIAN
      "6"  -> row #STD DEVIATION
      "7"  -> Enum.max(row)
      "8"  -> Enum.min(row)
      "9"  -> Enum.random(row)
      "10" -> Enum.filter(row, fn(x) -> String.match?("#{x}", ~r/^[0-9]+$/) end)       # NUMERIC
      "11" -> Enum.filter(row, fn(x) -> String.match?("#{x}", ~r/^[a-zA-Z]+$/) end)    # NON NUMERIC
      "12" -> Enum.filter(row, fn(x) -> String.match?("#{x}", ~r/^[a-zA-Z0-9]+$/) end) # ALPHANUMERIC
    end
  end


  def main do
    filename  = get_filepath
    filetype  = prompt_for_filetype
    columns   = target_columns
    operation = operation_type

    extract_from_file(filename, filetype, columns, operation)
    #IO.inspect extract_from_file("example", ",", :all, "1") ## FOR DEBUG
  end
end
