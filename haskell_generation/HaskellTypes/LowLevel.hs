{-# language LambdaCase #-}

module HaskellTypes.LowLevel where

import Helpers
  ( (==>), (.>) )

-- Types
type Literal = Integer

newtype ValueName =
  VN String deriving ( Eq, Ord )

data LiteralOrValueName =
  Literal Literal | ValueName ValueName

data ApplicationDirection =
  LeftApplication | RightApplication

newtype TupleMatching =
  TM [ ValueName ]

data Abstraction =
  ValueNameAb ValueName | TupleMatching TupleMatching

newtype Abstractions =
  As [ Abstraction ]

-- Show instances
instance Show ValueName where
  show = \(VN n) -> n

instance Show LiteralOrValueName where
  show = \case
    Literal l -> show l
    ValueName vn -> show vn

instance Show ApplicationDirection where
  show = \case
    LeftApplication -> "==>"
    RightApplication -> "<=="

instance Show TupleMatching where
  show = \(TM vns) ->
    "(" ++ init vns==>concatMap (show .> (++ ", ")) ++ show (last vns) ++ ")"

instance Show Abstraction where
  show = \case
    ValueNameAb vn -> show vn
    TupleMatching tm -> show tm

instance Show Abstractions where
  show = \(As as) -> as==>concatMap (show .> (++ " -> "))
