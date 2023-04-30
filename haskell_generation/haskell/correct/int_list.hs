{-# language LambdaCase #-}

-- AllButFirst

class AllButFirst a b where
  get_all_but_1st :: a -> b

instance AllButFirst (a, b) b where
  get_all_but_1st = \(_, b) -> b

instance AllButFirst (a, b, c) (b, c) where
  get_all_but_1st = \(_, b, c) -> (b, c)

instance AllButFirst (a, b, c, d) (b, c, d) where
  get_all_but_1st = \(_, b, c, d) -> (b, c, d)

instance AllButFirst (a, b, c, d, e) (b, c, d, e) where
  get_all_but_1st = \(_, b, c, d, e) -> (b, c, d, e)

-- HasFirst

class HasFirst a b where
  get_1st :: a -> b

instance HasFirst (a, b) a where
  get_1st = \(a, _) -> a

instance HasFirst (a, b, c) a where
  get_1st = \(a, _, _) -> a

instance HasFirst (a, b, c, d) a where
  get_1st = \(a, _, _, _) -> a

instance HasFirst (a, b, c, d, e) a where
  get_1st = \(a, _, _, _, _) -> a

-- HasSecond

class HasSecond a b where
  get_2nd :: a -> b

instance HasSecond (a, b) b where
  get_2nd = \(_, b) -> b

instance HasSecond (a, b, c) b where
  get_2nd = \(_, b, _) -> b

instance HasSecond (a, b, c, d) b where
  get_2nd = \(_, b, _, _) -> b

instance HasSecond (a, b, c, d, e) b where
  get_2nd = \(_, b, _, _, _) -> b

-- HasThird

class HasThird a b where
  get_3rd :: a -> b

instance HasThird (a, b, c) c where
  get_3rd = \(_, _, c) -> c

instance HasThird (a, b, c, d) c where
  get_3rd = \(_, _, c, _) -> c

instance HasThird (a, b, c, d, e) c where
  get_3rd = \(_, _, c, _, _) -> c

-- HasFourth

class HasFourth a b where
  get_4th :: a -> b

instance HasFourth (a, b, c, d) d where
  get_4th = \(_, _, _, d) -> d

instance HasFourth (a, b, c, d, e) d where
  get_4th = \(_, _, _, d, _) -> d

-- HasFifth

class HasFifth a b where
  get_5th :: a -> b

instance HasFifth (a, b, c, d, e) e where
  get_5th = \(_, _, _, _, e) -> e

-- main

main = print res

-- Generated

data IntHeadAndTail =
  CIntHeadAndTail { get_head :: Int, get_tail :: IntList }

instance Show IntHeadAndTail where
  show = \(CIntHeadAndTail head tail) ->
    "( " ++ 
    "head = " ++ show head ++ "\n, " ++ 
    "tail = " ++ show tail ++
    ")"

data IntList =
  Chead_and_tail IntHeadAndTail | Cempty

instance Show IntList where
  show = \case
    Chead_and_tail val -> "head_and_tail<==\n" ++ show val
    Cempty -> "empty"

apply_to_all :: (Int -> Int) -> IntList -> IntList
apply_to_all = \f -> \case
  Cempty -> Cempty
  Chead_and_tail value@(CIntHeadAndTail head tail) -> Chead_and_tail 
    (CIntHeadAndTail (f (get_head value)) (apply_to_all f (get_tail value)))

list :: IntList
list = Chead_and_tail 
  (CIntHeadAndTail (1) (Chead_and_tail 
  (CIntHeadAndTail (2) (Chead_and_tail 
  (CIntHeadAndTail (3) (Chead_and_tail 
  (CIntHeadAndTail (4) (Chead_and_tail 
  (CIntHeadAndTail (5) (Cempty))))))))))

res :: IntList
res = apply_to_all (\x -> x + 1) list
