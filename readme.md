# 2DLC

> 2-Dimensional Lambda Calculus

2DLC envisions an infinite grid of squares to represent the program. Each cell may contain text, a special operator, or be empty. The contents of non-empty cells combined with their positions relative to their orthogonally adjacent non-empty cell defines the semantics of the program. The semantics of 2DLC are defined based on Lambda Calculus.

## Text representation

2DLC may be represented textually. Each row is represented a line of text, and columns are represented by space-delimited characters. The length of each column in terms of characters should the same across each row to ensure the uniformity of the grid. Additional spaces may be used to align the grid.

## Syntax

In 2DLC, operations on squares occur over two directions across the grid, upwards and leftwards. Therefore each square may receive input from the right and bottom, and return output from the left and top, as seen below for the cell `K`.

```
  ^  
< K < 
  ^  
```

The order of operations of inputs and outputs from first to last is right, bottom, top, left, as seen below for the square K.

```
  3
4 K 1
  2
```

## Semantics

### Variables

```
x 
```

Represents a variable and may be any string of alphanumeric characters not beginning with a number.

### Application

```
. M
N
```

Represents function application, applying a function M to the argument N. `.` is a special operation which accepts a function from the right, and an argument from the bottom, and returns the result from either the top or left. It is also possible to apply functions to arguments directly by passing the arguments as input to the bottom or right of the function, as seen below. In the case of passing arguments from both the right and bottom, the function is first applied to the right argument, and the result is applied to the bottom argument

```
M     M N     M N
N             O
```

### Abstraction

```
(x) M
```

Represents a function definiton, taking as input the bound variable `x`, and returning the body `M` (which may contain `x`). `(x)` is a special operation which binds the variable x as a function parameter, and accepts the function body as its first input. The resulting function is returned from the top or left. Using the application rule, the function may be called by applying to the arguments passed from the bottom.

### Piping

To support spacing operations across the grid freely, the special operators `-` and `|` can be used to direct output along the grid.

```
M - N
```

The horizontal pipe accepts input from the right only, and passes it onwards to the left only.

```
M
|
N
```

The vertical pipe accepts input from the bottom only, and passes it onwards to the top only.

Notably, these special operators are not techincally necessary for 2DLC to be turing complete. A multi-directional pipe operator `p` could abstracted and defined as the identity function, as shown below, where `M` is some program which can freely use `p` as a multi-directional pipe operator.

```
(p) p M 
(x)
 x
```



## Examples

The $\Omega$ function:

```
(x) x
 |  x
 |
(x) x
    x
```

The Y combinator function:

```
(f) (x) f
     |  x
     |  x
     |  
    (x) f
        x
        x
```

or 

```
(f) (x) f x x
     |
    (x) f x x
        
```

```

## Extension

2DLC is flexible enough to support superset languages which could potentially add more special operators, pre-defined functions, and value types.
