{-# language
  MultiParamTypeClasses, FlexibleInstances, FunctionalDependencies,
  UndecidableInstances
#-}
module Haskell.Predefined where

import Prelude hiding (IO)
import qualified Prelude as P

type T0'WithIO = P.IO
type IO = T0'WithIO ()
type ListOf's = []

v0'div' :: Integral a => (a, a) -> a
v0'div' = uncurry div

v0'mod' :: Integral a => (a, a) -> a
v0'mod' = uncurry mod

print' :: Show a => a -> IO
print' = print

print_line' = putStrLn
get_line = getLine
split'to_words = words
apply'to_all_in' = uncurry map
throw_err' = error

v0'length :: [a] -> Int
v0'length = length

ignore'from' :: (Int, [a]) -> [a]
ignore'from' = uncurry drop

take'from' :: (Int, [a]) -> [a]
take'from' = uncurry take

do_nothing :: IO
do_nothing = return ()

from_string' :: Read a => String -> a
from_string' = read

wrap :: Monad m => a -> m a
wrap = return

v0'with_io :: a -> P.IO a
v0'with_io = return

-- IsFirst'
class IsFirst' a b | b -> a where
  p1st :: b -> a

instance IsFirst' a (a, b) where
  p1st = fst

instance IsFirst' a (a, b, c) where
  p1st = \(a, _, _) -> a

instance IsFirst' a (a, b, c, d) where
  p1st = \(a, _, _, _) -> a

instance IsFirst' a (a, b, c, d, e) where
  p1st = \(a, _, _, _, _) -> a

-- IsSecond'
class IsSecond' a b | b -> a where
  p2nd :: b -> a

instance IsSecond' b (a, b) where
  p2nd = snd

instance IsSecond' b (a, b, c) where
  p2nd = \(_, b, _) -> b

instance IsSecond' b (a, b, c, d) where
  p2nd = \(_, b, _, _) -> b

instance IsSecond' b (a, b, c, d, e) where
  p2nd = \(_, b, _, _, _) -> b

-- IsThird'
class IsThird' a b | b -> a where
  p3rd :: b -> a

instance IsThird' c (a, b, c) where
  p3rd = \(_, _, c) -> c

instance IsThird' c (a, b, c, d) where
  p3rd = \(_, _, c, _) -> c

instance IsThird' c (a, b, c, d, e) where
  p3rd = \(_, _, c, _, _) -> c

-- ChangeFirst'
class ChangeFirstTo' a b | b -> a where
  c1st :: a -> b -> b

instance ChangeFirstTo' a (a, b) where
  c1st = \a (_, b) -> (a, b)

instance ChangeFirstTo' a (a, b, c) where
  c1st = \a (_, b, c) -> (a, b, c)

instance ChangeFirstTo' a (a, b, c, d) where
  c1st = \a (_, b, c, d) -> (a, b, c, d)

instance ChangeFirstTo' a (a, b, c, d, e) where
  c1st = \a (_, b, c, d, e) -> (a, b, c, d, e)

-- ChangeSecond'
class ChangeSecondTo' a b | b -> a where
  c2nd :: a -> b -> b

instance ChangeSecondTo' b (a, b) where
  c2nd = \b (a, _) -> (a, b)

instance ChangeSecondTo' b (a, b, c) where
  c2nd = \b (a, _, c) -> (a, b, c)

instance ChangeSecondTo' b (a, b, c, d) where
  c2nd = \b (a, _, c, d) -> (a, b, c, d)

instance ChangeSecondTo' b (a, b, c, d, e) where
  c2nd = \b (a, _, c, d, e) -> (a, b, c, d, e)

-- ChangeThird'
class ChangeThirdTo' a b | b -> a where
  c3rd :: a -> b -> b

instance ChangeThirdTo' c (a, b, c) where
  c3rd = \c (a, b, _) -> (a, b, c)

instance ChangeThirdTo' c (a, b, c, d) where
  c3rd = \c (a, b, _, d) -> (a, b, c, d)

instance ChangeThirdTo' c (a, b, c, d, e) where
  c3rd = \c (a, b, _, d, e) -> (a, b, c, d, e)

-- P0'Has_Str_Rep
class P0'Has_Str_Rep a where
  v0'to_string :: a -> String

instance Show a => P0'Has_Str_Rep a where
  v0'to_string = show

-- FromTuple classes
class FromTuple2 a b c | c -> a b where
  ft2 :: (a, b) -> c

class FromTuple3 a b c d | d -> a b c where
  ft3 :: (a, b, c) -> d

class FromTuple4 a b c d e | e -> a b c d where
  ft4 :: (a, b, c, d) -> e

class FromTuple5 a b c d e f | f -> a b c d e where
  ft5 :: (a, b, c, d, e) -> f

-- FromTuple classes for regular tuples
instance FromTuple2 a b (a, b) where
  ft2 = id

instance FromTuple3 a b c (a, b, c) where
  ft3 = id

instance FromTuple4 a b c d (a, b, c, d) where
  ft4 = id

instance FromTuple5 a b c d e (a, b, c, d, e) where
  ft5 = id

