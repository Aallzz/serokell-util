{-# LANGUAGE Rank2Types   #-}
{-# LANGUAGE TypeFamilies #-}

-- | Extra operators on Lens
module Serokell.Util.Lens
       ( (%%=)
       , (%?=)
       , WrappedM (..)
       , _UnwrappedM
       ) where

import qualified Control.Lens               as L
import           Control.Monad.Reader       (ReaderT)
import           Control.Monad.State        (State, get, runState)
import           Control.Monad.Trans.Except (ExceptT, mapExceptT)
import           System.Wlog                (LoggerName, LoggerNameBox (..))

-- I don't know how to call these operators

-- | Similar to %= operator, but takes State action instead of (a -> a)
infix 4 %%=
(%%=) :: L.Lens' s a -> State a b -> State s b
(%%=) l ma = do
    attr <- L.view l <$> get
    let (res,newAttr) = runState ma attr
    l L..= newAttr
    return res

-- | Like %%= but with possiblity of failure
infix 4 %?=
(%?=) :: L.Lens' s a -> ExceptT t (State a) b -> ExceptT t (State s) b
(%?=) l = mapExceptT (l %%=)

-- | Similar to `Wrapped`, but for `Monad`s.
class Monad m => WrappedM m where
    type UnwrappedM m :: * -> *
    _WrappedM :: L.Iso' (m a) (UnwrappedM m a)

_UnwrappedM :: WrappedM m => L.Iso' (UnwrappedM m a) (m a)
_UnwrappedM = L.from _WrappedM

instance Monad m => WrappedM (LoggerNameBox m) where
    type UnwrappedM (LoggerNameBox m) = ReaderT LoggerName m
    _WrappedM = L.iso loggerNameBoxEntry LoggerNameBox
