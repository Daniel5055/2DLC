Can I create a space efficient fibonacci function f?

```
(f) (n) . . if
        | 1 +  f - 1
        |   f    n
        < 2 -  2
        n   n
```

```
(f) (n) . if < 2 
        | 1  n
        |    
        + f  - 1
        f    n
        - 2
        n

(f) (n) . if < 2 
        | 1  n
        |    
        + f  - 1
        f    n
        - 2
        n
```

```
(f) (n) . if + f 
        | 1  | - 1
        |    f L n 
        < 2  - 2  
        n    n 

```


, operator applies second argument to first

```
(,) - - - - M
 |
(x) (y)
     . y
     x
```
