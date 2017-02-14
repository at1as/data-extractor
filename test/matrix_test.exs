require Matrix

defmodule MatrixTest do
  use ExUnit.Case, async: true

  test "Matrix.get_at()" do
    matrix = [[0, 1, 2],
              [3, 4, 5],
              [6, 7, 8]]

    assert Matrix.get_at(matrix, 0, 0) == 0
    assert Matrix.get_at(matrix, 1, 0) == 3 
    assert Matrix.get_at(matrix, 2, 0) == 6
    assert Matrix.get_at(matrix, 0, 1) == 1
    assert Matrix.get_at(matrix, 1, 1) == 4
    assert Matrix.get_at(matrix, 2, 1) == 7
    assert Matrix.get_at(matrix, 0, 2) == 2
    assert Matrix.get_at(matrix, 1, 2) == 5
    assert Matrix.get_at(matrix, 2, 2) == 8
  end


  test "Matrix.transpose()" do
    # 1D Matrix -> x
    matrix = [1,2,3,4,5,6]
    assert Matrix.transpose(matrix) == [[1], [2], [3], [4], [5], [6]]
    
    # 1D Matrix -> y (n.b. Matrix are always returned as 2D since operations occur per row)
    matrix = [[1],[2],[3],[4],[5],[6]]
    assert Matrix.transpose(matrix) == [[1,2,3,4,5,6]]
  
    # Identity Matrix
    matrix = [[1,0], [0,1]]
    assert Matrix.transpose(matrix) == [[1,0], [0,1]]
    
    # From wide to tall
    matrix = [[1, 2, 3, 4], [5, 6, 7, 8]]
    assert Matrix.transpose(matrix) == [[1,5], [2,6], [3,7], [4,8]]
    
    # From tall to wide
    matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
    assert Matrix.transpose(matrix) == [[1,4,7,10], [2,5,8,11], [3,6,9,12]]
    
    # Matrix starts with nil
    matrix = [[nil, 2, 3], [4, 5, 6]]
    assert Matrix.transpose(matrix) == [[nil, 4], [2, 5], [3, 6]]
    
    # Matrix all nil
    matrix = [[nil, nil, nil, nil], [nil, nil, nil, nil]]
    assert Matrix.transpose(matrix) == [[nil, nil], [nil, nil], [nil, nil], [nil, nil]]
    
    # Matrix empty -> Should return empty with no rows
    matrix = []
    assert Matrix.transpose(matrix) == []
  end


  test "Matrix.replace_at" do
    matrix = [[0, 1, 2],
              [3, 4, 5],
              [6, 7, 8]]
  
    assert Matrix.replace_at(matrix, 0, 0, "X") == [["X", 1, 2], [3, 4, 5], [6, 7, 8]]
    assert Matrix.replace_at(matrix, 1, 0, "X") == [[0, 1, 2], ["X", 4, 5], [6, 7, 8]]
    assert Matrix.replace_at(matrix, 2, 0, "X") == [[0, 1, 2], [3, 4, 5], ["X", 7, 8]]
    assert Matrix.replace_at(matrix, 0, 1, "X") == [[0, "X", 2], [3, 4, 5], [6, 7, 8]]
    assert Matrix.replace_at(matrix, 1, 1, "X") == [[0, 1, 2], [3, "X", 5], [6, 7, 8]]
    assert Matrix.replace_at(matrix, 2, 1, "X") == [[0, 1, 2], [3, 4, 5], [6, "X", 8]]
    assert Matrix.replace_at(matrix, 0, 2, "X") == [[0, 1, "X"], [3, 4, 5], [6, 7, 8]]
    assert Matrix.replace_at(matrix, 1, 2, "X") == [[0, 1, 2], [3, 4, "X"], [6, 7, 8]]
    assert Matrix.replace_at(matrix, 2, 2, "X") == [[0, 1, 2], [3, 4, 5], [6, 7, "X"]]
  end
end
