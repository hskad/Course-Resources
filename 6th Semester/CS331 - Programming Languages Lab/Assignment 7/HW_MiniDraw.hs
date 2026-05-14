{-# OPTIONS_GHC -Wno-unused-top-binds #-}
-- HW_MiniDraw.hs
-- Name:
-- Student ID:

module HW_MiniDraw where

import Data.Monoid

-- =====================
-- BASIC TYPES
-- =====================

type Program = [Cmd]
type Point = (Int, Int)
type Scene = [(Shape, Point)]

data Expr
  = Val Int
  | Add Expr Expr
  | Mul Expr Expr
  deriving (Eq, Show)

data Shape
  = Circle Expr
  | Rect Expr Expr
  deriving (Eq, Show)

data Cmd
  = Draw Shape
  | Move Expr Expr
  deriving (Eq, Show)

-- =====================
-- PART 1: Expressions
-- =====================

-- | >>> evalExpr (Add (Val 2) (Mul (Val 3) (Val 4)))
-- 14
evalExpr :: Expr -> Int
evalExpr (Val n)     = n
evalExpr (Add e1 e2) = evalExpr e1 + evalExpr e2
evalExpr (Mul e1 e2) = evalExpr e1 * evalExpr e2

-- =====================
-- PART 2: Functor
-- =====================

data AnnShape a
  = ACircle a Int
  | ARect a Int Int
  deriving (Eq, Show)

instance Functor AnnShape where
  fmap f (ACircle ann r)   = ACircle (f ann) r
  fmap f (ARect ann w h)   = ARect (f ann) w h

-- =====================
-- PART 3: Applicative Validation
-- =====================

data Validation e a
  = Failure e
  | Success a
  deriving (Eq, Show)

instance Functor (Validation e) where
  fmap _ (Failure e) = Failure e
  fmap f (Success a) = Success (f a)

instance Monoid e => Applicative (Validation e) where
  pure = Success
  Failure e1 <*> Failure e2 = Failure (e1 <> e2)
  Failure e1 <*> _          = Failure e1
  _          <*> Failure e2 = Failure e2
  Success f  <*> Success a  = Success (f a)

-- | >>> validateExpr (Val 5)
-- Success 5
validateExpr :: Expr -> Validation [String] Int
validateExpr e =
  let n = evalExpr e
  in Success n

validateShape :: Shape -> Validation [String] Shape
validateShape s@(Circle r) =
  let rv = evalExpr r
  in if rv > 0
       then Success s
       else Failure ["Circle radius must be positive, got: " ++ show rv]
validateShape s@(Rect w h) =
  let wv = evalExpr w
      hv = evalExpr h
      wErr = if wv > 0 then Success s else Failure ["Rectangle width must be positive, got: " ++ show wv]
      hErr = if hv > 0 then Success s else Failure ["Rectangle height must be positive, got: " ++ show hv]
  in case (wErr, hErr) of
       (Failure e1, Failure e2) -> Failure (e1 <> e2)
       (Failure e1, _)          -> Failure e1
       (_, Failure e2)          -> Failure e2
       _                        -> Success s

-- =====================
-- PART 4: Monad Execution
-- =====================

type Exec a = Point -> Either String (a, Point, Scene)

-- Monad-style bind for Exec
bindExec :: Exec a -> (a -> Exec b) -> Exec b
bindExec ma f pt =
  case ma pt of
    Left err          -> Left err
    Right (a, pt', s1) ->
      case f a pt' of
        Left err           -> Left err
        Right (b, pt'', s2) -> Right (b, pt'', s1 ++ s2)

-- Return for Exec
returnExec :: a -> Exec a
returnExec a pt = Right (a, pt, [])

runCmd :: Cmd -> Exec ()
runCmd (Move ex ey) pt =
  let x = evalExpr ex
      y = evalExpr ey
  in case validateExpr ex of
       Failure errs -> Left (unlines errs)
       Success _    ->
         case validateExpr ey of
           Failure errs -> Left (unlines errs)
           Success _    -> Right ((), (x, y), [])
runCmd (Draw shape) pt =
  case validateShape shape of
    Failure errs -> Left (unlines errs)
    Success s    -> Right ((), pt, [(s, pt)])

-- | >>> runProgram [Draw (Circle (Val 5))]
-- Right [(Circle (Val 5),(0,0))]
runProgram :: Program -> Either String Scene
runProgram cmds =
  case go cmds (0, 0) of
    Left err          -> Left err
    Right (_, _, scene) -> Right scene
  where
    go []     pt = Right ((), pt, [])
    go (c:cs) pt =
      case runCmd c pt of
        Left err            -> Left err
        Right (_, pt', s1)  ->
          case go cs pt' of
            Left err             -> Left err
            Right (_, pt'', s2)  -> Right ((), pt'', s1 ++ s2)

-- =====================
-- PART 5: Monoid Logging
-- =====================

newtype Log = Log [String]
  deriving (Eq, Show)

instance Semigroup Log where
  Log xs <> Log ys = Log (xs ++ ys)

instance Monoid Log where
  mempty = Log []

-- Output type combining a scene with a log
data Out = Out
  { outScene :: Scene
  , outLog   :: Log
  }
  deriving (Eq, Show)

instance Semigroup Out where
  Out s1 l1 <> Out s2 l2 = Out (s1 ++ s2) (l1 <> l2)

instance Monoid Out where
  mempty = Out [] mempty

-- Logging execution: runs a program and produces an Out with log entries
runCmdLogged :: Cmd -> Point -> Either String (Point, Out)
runCmdLogged (Move ex ey) pt =
  let x = evalExpr ex
      y = evalExpr ey
      newPt = (x, y)
      msg = "Moved to " ++ show newPt
  in Right (newPt, Out [] (Log [msg]))
runCmdLogged (Draw shape) pt =
  case validateShape shape of
    Failure errs -> Left (unlines errs)
    Success s ->
      let msg = case s of
                  Circle _ -> "Drew circle at " ++ show pt
                  Rect _ _ -> "Drew rectangle at " ++ show pt
      in Right (pt, Out [(s, pt)] (Log [msg]))

runProgramLogged :: Program -> Either String Out
runProgramLogged cmds = go cmds (0, 0) mempty
  where
    go []     _  acc = Right acc
    go (c:cs) pt acc =
      case runCmdLogged c pt of
        Left err          -> Left err
        Right (pt', out)  -> go cs pt' (acc <> out)

-- =====================
-- PART 6: Optimization
-- =====================

optimizeExpr :: Expr -> Expr
optimizeExpr (Val n)     = Val n
optimizeExpr (Add e1 e2) =
  let o1 = optimizeExpr e1
      o2 = optimizeExpr e2
  in case (o1, o2) of
       (Val a, Val b) -> Val (a + b)
       _              -> Add o1 o2
optimizeExpr (Mul e1 e2) =
  let o1 = optimizeExpr e1
      o2 = optimizeExpr e2
  in case (o1, o2) of
       (Val a, Val b) -> Val (a * b)
       _              -> Mul o1 o2

optimizeCmd :: Cmd -> Cmd
optimizeCmd (Draw (Circle r))   = Draw (Circle (optimizeExpr r))
optimizeCmd (Draw (Rect w h))   = Draw (Rect (optimizeExpr w) (optimizeExpr h))
optimizeCmd (Move ex ey)        = Move (optimizeExpr ex) (optimizeExpr ey)

optimizeProg :: Program -> Program
optimizeProg = map optimizeCmd

-- =====================
-- SAMPLE PROGRAM
-- =====================

example :: Program
example =
  [ Draw (Circle (Val 5))
  ,
 Move (Val 10) (Val 20)
  ,
 Draw (Rect (Val 4) (Val 6))
  ]
