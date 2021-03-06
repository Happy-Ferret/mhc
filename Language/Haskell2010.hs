module Language.Haskell2010 where

import qualified Control.Monad.Identity       as Identity
import qualified Control.Monad.State          as State
import qualified Data.Maybe                   as Maybe
import qualified Language.Haskell2010.Lexing  as Lexing
import qualified Language.Haskell2010.Parsing as Parsing
import qualified Language.Haskell2010.QId     as QId

type AST = Parsing.Module'

splitQId :: String -> [String]
splitQId = fst . Identity.runIdentity . QId.runLexing . QId.lex QId.semanticActions

parse :: String -> Maybe AST
parse s =
  let (tokens0, s') = flip State.evalState (0, 0) $ Lexing.runLexing $ Lexing.lex Lexing.semanticActions s in
    case s' of
      [] ->
        let tokens = Maybe.mapMaybe (\tk -> case tk of {Right tok -> Just tok; Left _ -> Nothing}) tokens0 in
          case Identity.runIdentity $ Parsing.parse Parsing.semanticActions tokens of
            Left _ ->
              Nothing
            Right (result, tokens') -> do
              case tokens' of
                [] ->
                  Just result
                _ ->
                  Nothing
      _ ->
        Nothing
