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
    filepath = IO.gets "\n>> Where is your file located?\n"
    filepath = cleanup_str(filepath)

    if file_exists?(filepath) do
      filepath
    else
      IO.puts ">> File not found."
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
        IO.puts ">> Please enter a valid option"
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
        IO.puts ">> Please enter a valid value"
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
        IO.puts ">> Enter a valid integer value"
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
        sorted_list = Enum.sort(row)
        first  = Enum.at(sorted_list, round(len/2))
        second = Enum.at(sorted_list, round(len/2) + 1)

        (first + second)/2

      rem(row, 2) == 1 ->
        row
        |> Enum.sort
        |> Enum.at(round(((len - 1)/2) + 1))
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
    IO.puts "\nOutput:\n"
    Enum.each(n_by_m_matrix, fn(row) -> 
      IO.puts Enum.join(row, delimiter)
    end)
    IO.puts "\n"
  end


  def interactive_cli() do
    filename  = get_filepath()
    filetype  = prompt_for_filetype()
    columns   = target_columns()
    operation = operation_type()

    extract_from_file(filename, filetype, columns, operation) |> printer(filetype)
  end


  def posix_cli(args) do
      parsed_args = OptionParser.parse(args)

      {kv_args, _, arg_list} = parsed_args

      filename  = Keyword.get(kv_args, :filename)
      {_, delimiter} = Enum.filter(arg_list, fn {a, _} -> a in ["-d", "--delimiter"] end) |> List.first || {_, ","}
      {_, columns}   = Enum.filter(arg_list, fn {a, _} -> a in ["-c", "--columuns"] end)  |> List.first || {_, "all"}
      {_, operation} = Enum.filter(arg_list, fn {a, _} -> a in ["-o", "--operation"] end) |> List.first
      
      if Enum.any?([filename, delimiter, columns, operation], fn(x) -> x == nil end) do
        IO.puts "\nInvalid args provided for --filename --delimiter --columns --operation"
        main(args)
      end

      IO.puts "Running with args: --filename #{filename} --delimiter #{delimiter} --columns #{columns} --operation #{operation}"
      extract_from_file(filename, delimiter, columns, operation) |> printer(delimiter)
  end


  def main(args) do
    
    if "--interactive" in args || "-i" in args do
      IO.puts "Starting Interactive CLI... "
      interactive_cli()
    else
      posix_cli(args)
    end
  end

end