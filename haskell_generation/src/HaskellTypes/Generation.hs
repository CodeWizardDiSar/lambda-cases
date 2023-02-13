{-# language LambdaCase #-}

module HaskellTypes.Generation where

import Control.Monad.State
  ( State, get, modify )
import qualified Data.Map as M
  ( Map, lookup, insert, insertWith )
--import Control.Monad.Trans.Except ( ExceptT )

import Helpers
  ( (.>), (==>) )

import HaskellTypes.LowLevel
  ( ValueName(..) )
import HaskellTypes.Types
  ( TypeName(..), BaseType(..), ValueType(..), FieldAndType, CaseAndMaybeType
  , FieldsOrCases )
import HaskellTypes.AfterParsing
  ( ValType(..), ValFieldsOrCases(..) )

-- All:
-- Types, get fields, update fields, value_map operations, type_map operations

-- Types: ValueMap, TypeMap, GenState, Stateful
type ValueMap =
  M.Map ValueName [ ValueType ]

type ValMap =
  M.Map ValueName [ ValType ]

type TypeMap =
  M.Map TypeName FieldsOrCases

type ValTypeMap =
  M.Map TypeName ValFieldsOrCases

data GenState = GS
  { indent_level :: Int
  , val_map :: ValMap, val_type_map :: ValTypeMap
  , value_map :: ValueMap, type_map :: TypeMap }

type Stateful = State GenState

-- get fields: get_from_state, get_indent_level, get_value_map, get_type_map
get_from_state = ( \f -> get >>= f .> return )
  :: (GenState -> a) -> Stateful a

(get_indent_level, get_val_map, get_val_type_map, get_value_map, get_type_map) =
  (indent_level, val_map, val_type_map, value_map, type_map)==>
  \(i, vm, vtm, v, t) ->
    ( get_from_state i, get_from_state vm, get_from_state vtm, get_from_state v
    , get_from_state t )
  :: ( Stateful Int, Stateful ValMap, Stateful ValTypeMap
     , Stateful ValueMap, Stateful TypeMap )

-- update fields: update_indent_level, update_value_map, update_type_map
(update_indent_level, update_val_map, update_val_type_map, update_value_map,
 update_type_map) =
  ( \il -> modify ( \s -> s { indent_level = il } )
  , \vm -> modify ( \s -> s { val_map = vm } ) 
  , \vtm -> modify ( \s -> s { val_type_map = vtm } )
  , \vm -> modify ( \s -> s { value_map = vm } ) 
  , \tm -> modify ( \s -> s { type_map = tm } )
  ) :: ( Int -> Stateful (), ValMap -> Stateful (), ValTypeMap -> Stateful ()
       , ValueMap -> Stateful (), TypeMap -> Stateful () )

-- val_map operations: val_map_insert, value_map_get
val_map_insert =
  (\vn vt -> get_val_map >>= M.insertWith (++) vn [vt] .> update_val_map)
  :: ValueName -> ValType -> Stateful ()

val_map_get = ( \vn -> get_val_map >>= M.lookup vn .> \case
  Nothing -> error $ "No definition for value: " ++ show vn
  Just vts -> case vts of
    [] -> undefined
    vt:_ -> return vt
  ) :: ValueName -> Stateful ValType

-- val_type_map operations:
-- val_type_map_exists_check, val_type_map_insert, val_type_map_get
val_type_map_exists_check = ( \tn -> get_val_type_map >>= M.lookup tn .> \case
  Just _ -> error $ "Type of the same name already defined: " ++ show tn
  Nothing -> return ()
  ) :: TypeName -> Stateful ()

val_type_map_insert =
  (\tn vfoc -> get_val_type_map >>= M.insert tn vfoc .> update_val_type_map)
  :: TypeName -> ValFieldsOrCases -> Stateful ()

val_type_map_get = ( \tn@(TN s) -> get_val_type_map >>= M.lookup tn .> \case
  Nothing -> error $ "No definition for type: " ++ s
  Just foc -> return foc
  ) :: TypeName -> Stateful ValFieldsOrCases

-- value_map operations: value_map_insert, value_map_get, value_map_pop
value_map_insert =
  (\vn vt -> get_value_map >>= M.insertWith (++) vn [vt] .> update_value_map)
  :: ValueName -> ValueType -> Stateful ()

value_map_get = ( \vn -> get_value_map >>= M.lookup vn .> \case
  Nothing -> error $ "No definition for value: " ++ show vn
  Just vts -> case vts of
    [] -> undefined
    vt:_ -> return vt
  ) :: ValueName -> Stateful ValueType

value_map_pop = ( \vn -> get_value_map >>= \vm -> M.lookup vn vm ==> \case
  Nothing -> error $ "Should not happen: popped on non-existing value" ++ show vn
  Just vts -> case vts of
    [] -> error $
      "Should not happen: popped on empty stack of type for value" ++ show vn
    vt : vts -> update_value_map $ M.insert vn vts vm
  ) :: ValueName -> Stateful ()

-- type_map operations: type_map_exists_check, type_map_insert, type_map_get
type_map_exists_check = ( \tn -> get_type_map >>= M.lookup tn .> \case
  Just _ -> error $ "Type of the same name already defined: " ++ show tn
  Nothing -> return ()
  ) :: TypeName -> Stateful ()

type_map_insert =
  (\tn foc -> get_type_map >>= M.insert tn foc .> update_type_map)
  :: TypeName -> FieldsOrCases -> Stateful ()

type_map_get = ( \tn@(TN s) -> get_type_map >>= M.lookup tn .> \case
  Nothing -> error $ "No definition for type: " ++ s
  Just foc -> return foc
  ) :: TypeName -> Stateful FieldsOrCases
