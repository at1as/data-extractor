require ExUnit
require DataExtractor

ExUnit.start

defmodule RunTest do
  use ExUnit.Case, async: true

  test "cleanup_string" do
    assert DataExtractor.cleanup_str("\n Hello World! \n") == "Hello World!"
    assert DataExtractor.cleanup_str(" Hello World! ") == "Hello World!"
    assert DataExtractor.cleanup_str("\nHello World!\n") == "Hello World!"
    assert DataExtractor.cleanup_str("\n\n\nHello World!\n\n\n") == "Hello World!"
  end

  """
    Numeric Operation
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
    """


  test "test matrix sum" do
    # Filepath, comma separated, all columns, SUM
    output  = DataExtractor.extract_from_file("./test/random_values.csv", ",", "1", "1") |> Enum.at(0)
    desired = [3996]
    
    assert output == desired
  end

  test "test matrix subtract" do
    output  = DataExtractor.extract_from_file("./test/example-repeating-rows.csv", ",", "1", "2") |> Enum.at(0)
    assert output == [-998]
  end
  
  test "test matrix multiply" do
    output  = DataExtractor.extract_from_file("./test/example-repeating-rows.csv", ",", "1", "3") |> Enum.at(0)
    assert output == [1.0]
  end

  test "test matrix average" do
    output  = DataExtractor.extract_from_file("./test/random_values.csv", ",", "1", "4") |> Enum.at(0)
    assert output == [1]
  end



  test "test csv specific column" do
    output = DataExtractor.extract_from_file("./test/random_values.csv", ",", "1", "1") |> Enum.at(0)
    assert Enum.count(output) == 1
  end
  
  test "test csv all columns" do
    output = DataExtractor.extract_from_file("./test/random_values.csv", ",", :all, "2") |> Enum.at(0)
    assert Enum.count(output) == 18
  end
  
  test "test csv range from x to x" do
    output = DataExtractor.extract_from_file("./test/random_values.csv", ",", "2-2", "4") |> Enum.at(0)
    assert Enum.count(output) == 1
  end
  
  test "test csv range from x to x+1" do
    output = DataExtractor.extract_from_file("./test/random_values.csv", ",", "2-3", "7") |> Enum.at(0)
    assert Enum.count(output) == 2
  end
  
  test "test csv range from x to x+5" do
    output = DataExtractor.extract_from_file("./test/random_values.csv", ",", "2-7", "8") |> Enum.at(0)
    assert Enum.count(output) == 6
  end

end
