require IEx
require Matrix
require OptionParser

defmodule DataExtractor do
  
  alias DataExtractor


  def cleanup_str(input_string) do
    input_string
    |> String.trim("\n")
    |> String.trim(" ")
  end


  def get_range(range_str) do
    [from, to] = String.split(range_str, "-")
    Range.new(from, to)
  end


  def get_filepath do
    filepath = IO.gets "\nWhere is your file located?\n"
    filepath = cleanup_str(filepath)

    if file_exists?(filepath) do
      filepath
    else
      IO.puts "File not found."
      get_filepath()
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
        prompt_for_filetype()
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
      String.match?(target, ~r/^[\d]+$/) ->
        target

      String.match?(target, ~r/^[0-9]+\-[0-9]+$/) ->
        get_range(target)

      "all" == target ->
        :all

      true ->
        IO.puts "Please enter a valid value"
        target_columns()
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
        operation_type()
    end
  end


  def split_line(line, delimeter) do
    String.split(line, delimeter)
  end


  def columns(line_portions, bounds) do
    cond do
      is_atom(bounds) and bounds == :all ->
        line_portions

      is_bitstring(bounds) and (String.split(bounds, "-") |> Enum.count == 2) ->
        [first, second] = String.split(bounds, "-") |>
                          Enum.map(fn x -> 
                            Enum.at(Tuple.to_list(Integer.parse(x)), 0)
                          end)

        Enum.drop(line_portions, first) |>
        Enum.take(second - first + 1)
      
      
      Integer.parse(bounds) != :error ->
        [Enum.at(line_portions, Enum.at(Tuple.to_list(Integer.parse(bounds)), 0))]
      
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
    file_lines  = String.split(file, "\n") |>
                  Enum.reject(fn(x) -> x == "" end)
    
    matrix = Enum.map(file_lines, fn(x) ->
      extract_from_line(x, type, columns) 
    end)
   
    Matrix.transpose(matrix)  
    |> Task.async_stream(DataExtractor, :operation, [operation])
    |> Enum.map(fn {:ok, row} -> row end)
    |> Matrix.transpose
  end


  def median(row) do
    len = Enum.count(row)
    
    cond do
      rem(row, 2) == 0 ->
        sorted_list = Enum.sort
        first  = sorted_list.at(round(len/2))
        second = sorted_list.at(round(len/2) + 1)

        (first + second)/2

      rem(row, 2) == 1 ->
        row
        |> Enum.sort
        |> List.at(round(((len - 1)/2) + 1))
    end
  end


  def operation(row, operation) do
    row = Enum.map(row, &Float.parse(&1)) |>
          Enum.map(fn {x, _} -> x end)

    case operation do
      "1"  -> [ Enum.sum(row) ]
      "2"  -> [ Enum.reduce(row, fn x, acc -> acc - x end) ]
      "3"  -> [ Enum.reduce(row, fn x, acc -> acc * x end) ]
      "4"  -> [ Enum.reduce(row, fn x, acc -> acc + x end) / Enum.count(row) ]
      "5"  -> [ median(row) ]
      "6"  -> row #TODO: STD DEVIATION
      "7"  -> [ Enum.max(row) ]
      "8"  -> [ Enum.min(row) ]
      "9"  -> [ Enum.random(row) ]
      "10" -> Enum.filter(row, fn(x) -> String.match?("#{x}", ~r/^[0-9.]+$/) end)       # NUMERIC
      "11" -> Enum.filter(row, fn(x) -> String.match?("#{x}", ~r/^[a-zA-Z.]+$/) end)    # NON NUMERIC
      "12" -> Enum.filter(row, fn(x) -> String.match?("#{x}", ~r/^[a-zA-Z0-9.]+$/) end) # ALPHANUMERIC
    end
  end

  
  def printer(n_by_m_matrix, delimiter) do
    Enum.each(n_by_m_matrix, fn(row) -> 
      IO.puts Enum.join(row, delimiter)
    end)
  end


  def main do
    OptionParser.parse(System.argv())

    filename  = get_filepath()
    filetype  = prompt_for_filetype()
    columns   = target_columns()
    operation = operation_type()

    extract_from_file(filename, filetype, columns, operation)
  end


  def test do

    #IO.puts "SUM:"

    #IO.puts "Starting #{:os.system_time(:millisecond)}\n"
    #extract_from_file("./test/random_values.csv", ",", :all, "1") |> printer(", ")
    #IO.puts "Done #{:os.system_time(:millisecond)}\n"

    #IO.puts "Extract Cells"
    #IO.puts "Starting #{:os.system_time(:millisecond)}\n"
    #extract_from_file("./test/random_values.csv", ",", :all, "11") |> printer(", ")
    #IO.puts "Done #{:os.system_time(:millisecond)}\n"
    """
    ## DEBUG
    IO.puts "\nALL\n"
    extract_from_file("example", ",", :all, "1") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "2") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "3") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "4") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "5") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "7") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "8") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "9") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "10") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "11") |> printer(", ")
    IO.puts "---"
    extract_from_file("example", ",", :all, "12") |> printer(", ")
    
    
    IO.puts "\n2\n"
    
    IO.inspect extract_from_file("example", ",", "2", "1") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "2") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "3") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "4") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "7") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "8") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "9") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "10") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "11") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2", "12") ## FOR DEBUG
    

    IO.puts "\n2-7\n"

    IO.inspect extract_from_file("example", ",", "2-7", "1") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "2") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "3") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "4") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "7") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "8") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "9") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "10") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "11") ## FOR DEBUG
    IO.inspect extract_from_file("example", ",", "2-7", "12") ## FOR DEBUG
    """
    nil
  end
end
