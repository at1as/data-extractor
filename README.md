# DataExtractor

An awk like script to parse data files and perform operations on the rows

### Operations

```
## Reduce operations

1)  Sum
2)  Subtract
3)  Multiply
4)  Average
5)  Median
6)  Standard Deviation

## Filter Operations
7)  Max
8)  Min
9)  Random Value
10) Numeric
11) Non-Numeric
12) Alpha Numeric
13) ASCII 
14) Non-ASCII
```


## Usage

Was built on Elixir 1.4 with OTP/19 on MacOS 10.10. Uses Elixir's built in Mix tool to build binary. Does not rely upon any external libraries.


### Build Binary

```
$ mix escript.build
```

### Run

```
# Interactive Mode (select options from list)
$ ./dataExtractor --interactive

# CLI Mode 
$ ./dataExtractor --filename test/example-repeating-rows --delimiter , --columns 2-5 --operation +
```

### Run Tests
```
$ mix test
```

## License

MIT License
