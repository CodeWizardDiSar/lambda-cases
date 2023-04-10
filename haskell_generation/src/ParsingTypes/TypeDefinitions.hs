module ParsingTypes.TypeDefinitions where

import Data.List (intercalate)
import Helpers ((==>))
import ParsingTypes.LowLevel (ValueName)
import ParsingTypes.Types (TypeName, ValueType)

-- All: Types, Show instances

-- Types:
-- ManyTNamesInParen, LeftTypeVars, RightTypeVars,
-- TypeConsAndVars,
-- Field, TupleTypeDef, OrTypeCase, OrTypeDef, TypeDefinition

data ManyTNamesInParen =
  ParenTypeNames TypeName TypeName [ TypeName ]

data LeftTypeVars = 
  NoLeftTypeVars | OneLeftTypeVar TypeName | ManyLeftTypeVars ManyTNamesInParen

data RightTypeVars = 
  NoRightTypeVars | OneRightTypeVar TypeName | ManyRightTypeVars ManyTNamesInParen

data TypeConsAndVars =
  TypeConsAndVars TypeName LeftTypeVars RightTypeVars

data Field =
  NameAndType ValueName ValueType 

data TupleTypeDef =
  ConsVarsAndFields TypeConsAndVars [ Field ]

data OrTypeCase =
  NameAndMaybeInT ValueName (Maybe ValueType)

data OrTypeDef =
  ConsVarsAndCases TypeConsAndVars OrTypeCase OrTypeCase [ OrTypeCase ]

data TypeDefinition =
  TupleTypeDef TupleTypeDef | OrTypeDef OrTypeDef

-- Show instances:
-- ManyTNamesInParen, LeftTypeVars, RightTypeVars,
-- TypeConsAndVars,
-- Field, TupleTypeDef, OrTypeCase, OrTypeDef, TypeDefinition

instance Show ManyTNamesInParen where
  show = \(ParenTypeNames tn1 tn2 tns) ->
      "(" ++ (tn1 : tn2 : tns)==>map show==>intercalate ", " ++ ")"

instance Show LeftTypeVars where
  show = \case
    NoLeftTypeVars -> ""
    OneLeftTypeVar type_name -> show type_name ++ "==>"
    ManyLeftTypeVars many_t_names_in_paren -> show many_t_names_in_paren ++ "==>"

instance Show RightTypeVars where
  show = \case
    NoRightTypeVars -> ""
    OneRightTypeVar type_name -> "<==" ++ show type_name
    ManyRightTypeVars many_t_names_in_paren -> "<==" ++ show many_t_names_in_paren

instance Show TypeConsAndVars where
  show = \(TypeConsAndVars type_name left_type_vars right_type_vars) ->
    show left_type_vars ++ show type_name ++ show right_type_vars

instance Show Field where
  show = \(NameAndType field_name field_type) ->
    show field_name ++ ": " ++ show field_type

instance Show TupleTypeDef where
  show = \(ConsVarsAndFields type_cons_and_vars fields) ->
    "\ntuple_type " ++ show type_cons_and_vars ++
    "\nvalue (" ++ fields==>map show==>intercalate ", "  ++ ")\n"

instance Show OrTypeCase where
  show = \(NameAndMaybeInT case_name maybe_case_type) ->
    show case_name ++ case maybe_case_type of 
      Just case_type -> "<==(value: " ++ show case_type ++ ")"
      Nothing -> ""

instance Show OrTypeDef where
  show = \(ConsVarsAndCases type_cons_and_vars case1 case2 cases) ->
    "\nor_type " ++ show type_cons_and_vars ++
    "\nvalues " ++ (case1 : case2 : cases)==>map show==>intercalate " | " ++ "\n"

instance Show TypeDefinition where
  show = \case
    TupleTypeDef tuple_type_def -> show tuple_type_def   
    OrTypeDef or_type_def -> show or_type_def
