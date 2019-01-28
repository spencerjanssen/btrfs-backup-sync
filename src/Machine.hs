{-# LANGUAGE LambdaCase, RankNTypes, FlexibleInstances #-}

module Machine where

import           System.Exit
import           Control.Monad.Fail
import           Control.Monad.Free

type MachineM a = Free Machine a

data Process = Process
    { cmd :: FilePath
    , args :: [FilePath]
    }

type Pipe = [Process]

data Machine a
    = ListDirectory FilePath ([FilePath] -> a)
    | CreateDirectoryIfMissing Bool FilePath a
    | CreateTempDirectory FilePath (FilePath -> a)
    | RenameDirectory FilePath FilePath a
    | CopyFile FilePath FilePath a
    | ExecPipe Pipe (ExitCode -> a)
    | Crash String

instance Functor Machine where
    fmap f = \case
        ListDirectory fp g              -> ListDirectory fp (f . g)
        CreateDirectoryIfMissing c fp x -> CreateDirectoryIfMissing c fp $ f x
        CreateTempDirectory fp g        -> CreateTempDirectory fp (f . g)
        RenameDirectory src dst x       -> RenameDirectory src dst $ f x
        CopyFile        src dst x       -> CopyFile src dst $ f x
        ExecPipe p g                    -> ExecPipe p (f . g)
        Crash r                         -> Crash r

listDirectory :: FilePath -> MachineM [FilePath]
listDirectory fp = liftF $ ListDirectory fp id

createDirectoryIfMissing :: Bool -> FilePath -> MachineM ()
createDirectoryIfMissing b fp = liftF $ CreateDirectoryIfMissing b fp ()

createTempDirectory :: FilePath -> MachineM FilePath
createTempDirectory fp = liftF $ CreateTempDirectory fp id

renameDirectory :: FilePath -> FilePath -> MachineM ()
renameDirectory src dst = liftF $ RenameDirectory src dst ()

copyFile :: FilePath -> FilePath -> MachineM ()
copyFile src dst = liftF $ CopyFile src dst ()

execPipe :: Pipe -> MachineM ExitCode
execPipe ps = liftF $ ExecPipe ps id

-- support stuff
instance MonadFail (Free Machine) where
    fail r = liftF $ Crash r
