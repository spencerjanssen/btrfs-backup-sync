{-# LANGUAGE LambdaCase, RankNTypes, FlexibleInstances #-}

module Machine where

import           System.Exit
import           Control.Monad.Fail

type MachineM a = Free Machine a

data Process = Process
    { cmd :: FilePath
    , args :: [FilePath]
    }

type Pipe = [Process]

data Machine a
    = ListDirectory FilePath ([FilePath] -> a)
    | CreateDirectoryIfMissing Bool FilePath a
    | CopyFile FilePath FilePath a
    | ExecPipe Pipe (ExitCode -> a)
    | Crash String

instance Functor Machine where
    fmap f = \case
        ListDirectory fp g                 -> ListDirectory fp (f . g)
        CreateDirectoryIfMissing c fp x -> CreateDirectoryIfMissing c fp $ f x
        CopyFile                 src dst x -> CopyFile src dst $ f x
        ExecPipe p g                       -> ExecPipe p (f . g)
        Crash r                            -> Crash r

listDirectory :: FilePath -> MachineM [FilePath]
listDirectory fp = liftF $ ListDirectory fp id

createDirectoryIfMissing :: Bool -> FilePath -> MachineM ()
createDirectoryIfMissing b fp = liftF $ CreateDirectoryIfMissing b fp ()

copyFile :: FilePath -> FilePath -> MachineM ()
copyFile src dst = liftF $ CopyFile src dst ()

execPipe :: Pipe -> MachineM ExitCode
execPipe ps = liftF $ ExecPipe ps id

-- support stuff
data Free f a
    = Pure a
    | Free (f (Free f a))

liftF :: Functor f => f a -> Free f a
liftF command = Free $ Pure <$> command

instance Functor f => Functor (Free f) where
    fmap f (Pure x) = Pure $ f x
    fmap f (Free g) = Free $ fmap (fmap f) g

instance Functor f => Applicative (Free f) where
    pure = Pure
    f <*> x = joinF $ fmap (\f' -> fmap f' x) f

joinF :: Functor f => Free f (Free f a) -> Free f a
joinF (Pure x) = x
joinF (Free x) = Free $ fmap joinF x

instance Functor f => Monad (Free f) where
    x >>= f = joinF $ fmap f x

instance MonadFail (Free Machine) where
    fail r = liftF $ Crash r

eval :: Monad m => (forall b . f b -> m b) -> Free f a -> m a
eval _ (Pure x) = pure x
eval f (Free g) = f g >>= eval f
