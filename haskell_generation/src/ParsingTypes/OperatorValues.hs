module ParsingTypes.OperatorValues where

import Data.List (intercalate)
import Helpers ((==>))
import ParsingTypes.LowLevel (Literal, ValueName, Input)

-- All (Types and Show instances):
-- Parenthesis, Tuple, MathApplication, BaseValue,
-- ApplicationDirection, FuncAppChain, MultExpr, PlusOrMinus, AddSubExpr,
-- Equality, PureOpExpr, InputOpExpr, OperatorExpression

-- Parenthesis

newtype Parenthesis =
  InnerExpression OperatorExpression 

instance Show Parenthesis where
  show = \(InnerExpression expr) -> "(" ++ show expr ++ ")"

-- Tuple

data Tuple =
  TupleExpressions OperatorExpression OperatorExpression [ OperatorExpression ]

instance Show Tuple where
  show = \(TupleExpressions expr1 expr2 exprs) ->
    "(" ++ map show (expr1 : expr2 : exprs)==>intercalate ", " ++ ")"

-- MathApplication

data MathApplication =
  NameAndInputExprs ValueName OperatorExpression [ OperatorExpression ]

instance Show MathApplication where
  show = \(NameAndInputExprs val_name expr1 exprs) ->
    show val_name ++ "(" ++ (expr1 : exprs)==>map show==>intercalate ", " ++ ")"

-- BaseValue

data BaseValue =
  Literal Literal | ValueName ValueName | Parenthesis Parenthesis |
  Tuple Tuple | MathApplication MathApplication

instance Show BaseValue where
  show = \case
    Parenthesis paren_val -> show paren_val
    Tuple tuple -> show tuple
    Literal lit -> show lit
    ValueName val_name -> show val_name
    MathApplication math_app -> show math_app

-- ApplicationDirection

data ApplicationDirection =
  LeftApplication | RightApplication

instance Show ApplicationDirection where
  show = \case
    LeftApplication -> "<=="
    RightApplication -> "==>"

-- FuncAppChain

data FuncAppChain =
  ValuesAndDirections BaseValue [ (ApplicationDirection, BaseValue) ]

instance Show FuncAppChain where
  show = \(ValuesAndDirections base_val app_dir_base_val_s) ->
    show base_val ++
    concatMap
      ( \(app_dir, base_val) -> show app_dir ++ show base_val ) app_dir_base_val_s

-- MultExpr

data MultExpr =
  Factors FuncAppChain [ FuncAppChain ]

instance Show MultExpr where
  show = \(Factors f1 fs) -> (f1 : fs)==>map show==>intercalate " * "

-- PlusOrMinus

data PlusOrMinus = 
  Plus | Minus

instance Show PlusOrMinus where
  show = \case
    Plus -> " + "
    Minus -> " - "

-- AddSubExpr

data AddSubExpr =
  FirstAndOpTermPairs MultExpr [ (PlusOrMinus, MultExpr) ]

instance Show AddSubExpr where
  show = \(FirstAndOpTermPairs term1 pairs) ->
    show term1 ++ concatMap ( \(op, term) -> show op ++ show term ) pairs

-- Equality

data Equality =
  EqualityTerms AddSubExpr AddSubExpr

instance Show Equality where
  show = \(EqualityTerms term1 term2) -> show term1 ++ " = " ++ show term2

-- PureOpExpr

data PureOpExpr =
  Equality Equality | AddSubExpr AddSubExpr

instance Show PureOpExpr where
  show = \case
    Equality equality -> show equality
    AddSubExpr add_sub_expr -> show add_sub_expr 

-- InputOpExpr

data InputOpExpr =
  InputAndPureOpExpr Input PureOpExpr 

instance Show InputOpExpr where
  show = \(InputAndPureOpExpr input pure_op_expr) ->
    show input ++ show pure_op_expr

-- OperatorExpression

data OperatorExpression =
  InputOpExpr InputOpExpr | PureOpExpr PureOpExpr

instance Show OperatorExpression where
  show = \case
    InputOpExpr input_op_expr -> show input_op_expr
    PureOpExpr pure_op_expr -> show pure_op_expr
