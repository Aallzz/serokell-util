-- | Common utilities.

module Serokell.Util.Common
       ( enumerate
       , indexModulo
       , indexModuloMay
       , indexedSubList
       ) where

import           Control.Monad.State (evalState, get, modify)
import           Data.List           (genericDrop, genericIndex, genericLength,
                                      genericTake)
import           Data.Maybe          (fromMaybe)

-- | Enumerate function is analogous to python's enumerate. It
-- takes sequences of values and returns sequence of pairs where the
-- first element is index and the second one is corresponding value.
-- It's roughly equivalent to `zip [0..]`.
-- > enumerate "Hello" = [(0,'H'),(1,'e'),(2,'l'),(3,'l'),(4,'o')]
enumerate
    :: (Num i, Enum i, Traversable t)
    => t a -> t (i, a)
enumerate values = evalState action 0
  where
    action = mapM step values
    step v = do
        i <- get
        modify succ
        return (i, v)

-- | Returns element of a list with given index modulo length of
-- list. Raises error if list is empty.
-- Examples:
-- indexModulo [1, 2, 3] 10 = 2
-- indexModulo [1, 0] 2 = 1
-- indexModulo [] 199 = error
indexModulo :: Integral i => [a] -> i -> a
indexModulo xs =
    fromMaybe (error "Serokell.Util.Common.indexModulo: empty list") .
    indexModuloMay xs

-- | Behaves like `indexModulo` but uses Maybe to report error
-- (i. e. empty list).
indexModuloMay :: Integral i => [a] -> i -> Maybe a
indexModuloMay xs i = genericIndex xs <$> indexModuloIndex xs i

indexModuloIndex :: Integral i => [a] -> i -> Maybe i
indexModuloIndex [] _ = Nothing
indexModuloIndex xs i = Just $ i `mod` genericLength xs

-- | indexedSubList (lo, hi) returns sublist of given list with
-- indices in [lo, hi).
-- Examples:
-- indexedSubList (2, 3) [0, 5, 10] = [(2, 10)]
-- indexedSubList (0, 2) [0, 5, 10] = [(0, 0), (1, 5)]
-- indexedSubList (0, 0) [0, 1, 11, 111] = []
-- indexedSubList (2000, 1000) [55, 47, 0, 1, 11, 111] = []
indexedSubList
    :: Integral i
    => (i, i) -> [a] -> [(i, a)]
indexedSubList (lo, hi)
    | hi <= lo = const []
    | otherwise = zip [lo .. hi - 1] . genericTake (hi - lo) . genericDrop lo
