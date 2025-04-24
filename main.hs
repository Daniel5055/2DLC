module Main where

-- Used to take union of lists in bv and fv defintions
-- Used to take difference of lists in bv and fv definitions
import Data.List ( (\\), union )

-- Used to do leftmost outermost search with maybe monad in eval'
import Control.Applicative ( (<|>))

import Data.Char (isSpace)

-------------------------------------------------------------------------------
-- Lambda Calculus

data LC = LVar Int | LApp LC LC | LAbs Int LC
instance Show LC where
    -- Making the lambda calculus prettier
    show (LVar ide) = show ide
    show (LApp (LAbs ide x) (LVar y)) = "(" ++ show (LAbs ide x) ++ ") " ++ show (LVar y)
    show (LApp (LAbs ide x) y) = "(" ++ show (LAbs ide x) ++ ") (" ++ show y ++ ")"
    show (LApp x (LVar y)) = show x ++ " " ++ show (LVar y)
    show (LApp x y) = show x ++ " (" ++ show y ++ ")"
    show (LAbs ide x) = "\\" ++ show ide ++ ". " ++ show x

-- Reduces x via beta reductions of the leftmost outermost redex
--  until there exist no more redexes to reduce
eval :: LC -> LC
eval x = maybe x eval (eval' x)

-- Reduces the leftmost outermost redex of the input lc
-- Return Nothing if there exists no redexes in the input lc
eval' :: LC -> Maybe LC
eval' (LApp (LAbs n x) y) = Just (substitute n x y)
eval' (LApp x y) =
    (`LApp` y) <$> eval' x
    <|>
    LApp x <$> eval' y
eval' (LAbs n x) = LAbs n <$> eval' x
eval' x = Nothing

-- Return the list of free variables for a given lc
fv :: LC -> [ Int ]
fv (LVar n) = [ n ]
fv (LApp x y) = fv x `union` fv y
fv (LAbs n x) = fv x \\ [n]

-- Return the list of bound variables for a given lc
bv :: LC -> [ Int ]
bv (LVar _) = []
bv (LApp x y) = bv x `union` bv y
bv (LAbs n x) = bv x `union` [n]

-- Substitute variable n in x for y
-- First defintion gives a massive boost in performance
substitute n x y
    | n `notElem` fv x = x

substitute n (LVar m) y
    | n == m = y
    | n /= m = LVar m

substitute n (LApp a b) y = LApp (substitute n a y) (substitute n b y)

substitute n (LAbs m x) y
    | n == m = LAbs m x
    | m `notElem` fv y = LAbs m (substitute n x y)
    | otherwise =
        let vars = bv x `union` fv x `union` bv y `union` fv y
            o = maximum vars + 1
        in LAbs o (substitute n (substitute m x (LVar o)) y)

-- Should never reach this case
substitute _ _ _ = error "Reached unreachable substitute case"

-------------------------------------------------------------------------------
-- 2DLC Square
             
data TDLC = SVar String TDLC TDLC |
            SApp TDLC TDLC |
            SAbs String TDLC TDLC |
            SVoid 
    deriving Show

type Env = (Int, [(String, Int)])

lup :: Env -> String -> Int
lup (_, []) _ = -1
lup (l, (n, i) : env) name
    | name == n = i
    | otherwise = lup (l, env) name

assign :: Env -> String -> Env
assign (i, rho) n = (i + 1, (n, i) : rho)

initEnv :: TDLC -> Env
initEnv prog = (n+1, zip vars [0..n])
    where
        vars = freeV prog
        n = (length vars - 1)
freeV :: TDLC -> [String]
freeV (SVoid) = []
freeV (SVar v s1 s2) = [v] `union` freeV s1 `union` freeV s2
freeV (SApp s1 s2) = freeV s1 `union` freeV s2
freeV (SAbs v s1 SVoid) = freeV s1 \\ [v]
freeV (SAbs v SVoid s1) = freeV s1 \\ [v]
freeV (SAbs v s1 s2) = (freeV s1 \\ [v]) `union` freeV s2

denote :: TDLC -> LC
denote prog = denot prog (initEnv prog)

-- Denotation function
denot :: TDLC -> Env -> LC 
denot (SVar v SVoid SVoid) env = LVar (lup env v)
denot (SVar v SVoid s1) env = LApp (LVar (lup env v)) (denot s1 env)
denot (SVar v s1 SVoid) env = LApp (LVar (lup env v)) (denot s1 env)
denot (SVar v s1 s2) env = LApp (LApp (LVar (lup env v)) (denot s1 env)) (denot s2 env)

denot (SApp SVoid SVoid) _ = error "Bro what"
denot (SApp s1 SVoid) env = denot s1 env
denot (SApp SVoid s1) env = denot s1 env
denot (SApp s1 s2) env = LApp (denot s1 env) (denot s2 env)

denot (SAbs v SVoid SVoid) _ = error "Bro noooo"
denot (SAbs v s1 SVoid) env = LAbs (fst env) (denot s1 (assign env v))
denot (SAbs v SVoid s1) env = LAbs (fst env) (denot s1 (assign env v))
denot (SAbs v s1 s2) env = LApp (LAbs (fst env) (denot s1 (assign env v))) (denot s2 env)

denot (SVoid) _ = error  "Ruh roh"

-- Parse function

-- Width Height Drid
data Grid = G Int Int [[String]]
    deriving Show

trim :: String -> String
trim = f . f
   where f = reverse . dropWhile isSpace

tokenise :: String -> Grid
tokenise t = G (length lens) (length ls) (map (reverse . (tokenise' [] lens)) ls)
    where
        ls = lines t
        lens = (map length . words . head) ls

tokenise' :: [String] -> [Int] -> String -> [String]
tokenise' tks [_] line = tk:tks
    where
        tk = trim line

tokenise' tks (l:lx) line
    | void line = tokenise' (" ":tks) lx " "
    | otherwise = 
        if dl == ' '
            then  tokenise' (tk:tks) lx rest
            else error "Incorrect format"
        where
            tk = trim (take l line)
            rest = drop (l+1) line
            dl = if length line - 1 >= l then line !! l else ' '

void :: String -> Bool
void = all (==' ')

cell :: Grid -> Int -> Int -> String
cell (G w h grid) x y
    | x < 0 = " "
    | y < 0 = " "
    | x >= w = " "
    | y >= h = " "
    | otherwise = (grid !! y) !! x


parse :: Grid -> TDLC
parse grid = parse' grid 0 0

parse' :: Grid -> Int -> Int -> TDLC
parse' g x y
    | void c = SVoid
    | c == "." =
        SApp s1 s2
    | head c == '(' && last c == ')' =
        SAbs (tail (init c)) s1 s2
    | otherwise = SVar c s1 s2
    where
        c = cell g x y
        s1 = if void (cell g (x+1) (y-1))
            then (parse' g (x+1) y)
            else SVoid
        s2 = parse' g x (y+1)

main = do
    prog <- readFile "prog.txt"
    print ((eval . denote . parse . tokenise) prog)




