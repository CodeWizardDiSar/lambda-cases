module Main where

import System.Process (callCommand)
import Text.Parsec (ParseError, (<|>), eof, many, parse, char, try)
import Text.Parsec.String (Parser)
import Control.Monad ((>=>))
import Control.Monad.State (evalState)
import Control.Monad.Trans.Except (runExceptT, catchE, throwE)

import GenerationState.InitialState (init_state)
import Helpers (Haskell, (.>), (==>), eof_or_spicy_nls)

import GenerationState.TypesAndOperations (Stateful, value_map_insert)

import ParsingTypes.TypeDefinitions (TypeDefinition)
import ParsingTypes.LowLevel (ValueName)
import ParsingTypes.Types (ValueType)
import ParsingTypes.Values (Values, ValueExpression)

import Parsers.TypeDefinitions (type_definition_p)
import Parsers.Values (values_p)

import Conversions.Types (val_type_conv)

import GenerationHelpers.ErrorMessages (Error)

import CodeGenerators.TypeDefinitions (type_definition_g)
import CodeGenerators.Values (values_g, values_to_list, insert_value_to_map)

-- All: Path, Constants, Types, Parsing, Generating Haskell, main

-- Path: Path
 
type Path = String 

-- Constants:
-- lcases_names, lcases_paths, generated_haskell_paths,
-- in_out_path_pairs, haskell_header

correct_names =
  map ("correct/" ++)
    [
    "my_gcd"
    , "ext_euc_no_tuple_type"
    , "ext_euc_tuple_type"
    , "pair"
    , "bool"
    , "possibly_int"
    , "int_list"
    , "int_list2"
    , "int_list3"
    , "hanoi"
    ]
  :: [ String ]

wrong_names =
  map ("wrong/" ++)
  [
  "bool"
  , "not_covered"
  , "duplicate"
  , "out_of_scope"
  , "out_of_scope2"
  , "out_of_scope3"
  , "out_of_scope4"
  , "or_t_use_fields"
  , "func_t_use_fields"
  , "not_func"
  , "not_func2"
  , "type_check_err"
  , "equ_err"
  , "add_err"
  ]
  :: [ String ]

all_names =
  correct_names ++ wrong_names
  :: [ String ]

paths =
  map ( \s -> "lcases/" ++ s ++ ".lc" ) all_names
  :: [ String ]

hs_paths =
  map ( \s -> "haskell/" ++ s ++ ".hs" ) all_names
  :: [ String ]

path_pairs = 
  zip paths hs_paths
  :: [ (Path, Path) ]

correct_hs_paths =
  map ( \s -> "haskell/" ++ s ++ ".hs" ) correct_names
  :: [ String ]

exec_paths = 
  map ( \s -> "executables/" ++ s ) correct_names
  :: [ String ]

exec_path_pairs = 
  zip correct_hs_paths exec_paths
  :: [ (Path, Path) ]

exec_path_pair_to_cmd = ( \(hs_path, exec_path) -> 
  callCommand $ "ghc -o " ++ exec_path ++ " " ++ hs_path
  ) :: (Path, Path) -> IO ()

haskell_header =
  "haskell_headers/haskell_code_header.hs"
  :: Path

-- Types: ValuesOrTypeDef, Program

data ValuesOrTypeDef =
  TypeDefinition TypeDefinition | Values Values deriving Show

newtype Program =
  ValsOrTypeDefsList [ ValuesOrTypeDef ]

-- Parsing: parse_lcases, parse_with, program_p, values_or_type_def_p

parse_lcases =
  parse program_p
  :: Path -> String -> Either ParseError Program

program_p =
  many (char '\n') *> (ValsOrTypeDefsList <$> many values_or_type_def_p) <* eof
  :: Parser Program

values_or_type_def_p =
  (TypeDefinition <$> type_definition_p <|> Values <$> values_p)
  <* eof_or_spicy_nls
  :: Parser ValuesOrTypeDef

-- Generating Haskell:
-- parse_err_or_sem_analysis,
-- sem_err_or_hs_to_file, run_sem_analysis, program_g
-- values_or_type_definition_g

read_and_gen_example = ( \(input_path, output_path) ->
  readFile input_path >>= \lcases_input ->
  parse_lcases input_path lcases_input ==> \parser_output ->
  parse_err_or_sem_analysis parser_output output_path
  ) :: (Path, Path) -> IO ()

parse_err_or_sem_analysis = ( \parser_output output_path ->
  case parser_output of 
    Left parse_error -> print parse_error
    Right program -> sem_err_or_hs_to_file program output_path
  ) :: Either ParseError Program -> Path -> IO ()

sem_err_or_hs_to_file = ( \program output_path ->
  run_sem_analysis program ==> \case
    Left (_, _, sem_err_msg) -> putStrLn sem_err_msg
    Right generated_haskell -> 
      readFile haskell_header >>= \header ->
      writeFile output_path $ header ++ generated_haskell
  ) :: Program -> Path -> IO ()

run_sem_analysis = ( \program ->
  program_g program ==> runExceptT ==> flip evalState init_state
  ) :: Program -> Either Error Haskell

program_g = ( \(ValsOrTypeDefsList vals_or_type_defs_list) ->
  mapM_ insert_value_to_map (vals_or_type_defs_to_list vals_or_type_defs_list) >>
  mapM values_or_type_definition_g vals_or_type_defs_list ==> fmap concat
  ) :: Program -> Stateful Haskell

vals_or_type_defs_to_list = ( \vals_or_type_defs_list ->
  concatMap vals_or_type_def_to_list vals_or_type_defs_list
  ) :: [ ValuesOrTypeDef ] -> [ (ValueName, ValueType, ValueExpression) ]

vals_or_type_def_to_list = ( \case 
  Values values -> values_to_list values
  TypeDefinition _ -> []
  ) :: ValuesOrTypeDef -> [ (ValueName, ValueType, ValueExpression) ]

values_or_type_definition_g = ( \case 
  Values values -> values_g values
  TypeDefinition type_definition -> type_definition_g type_definition
  ) :: ValuesOrTypeDef -> Stateful Haskell

-- main

main =
  mapM_ read_and_gen_example path_pairs
  >>
  mapM_ exec_path_pair_to_cmd exec_path_pairs >>
  callCommand "rm haskell/correct/*.hi haskell/correct/*.o" >>
  callCommand "for f in ./executables/correct/*; do echo \"\n$f\n\"; $f; done"
  :: IO ()
