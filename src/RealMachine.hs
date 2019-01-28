module RealMachine
    ( run
    )
where

import           Machine
import qualified System.Directory              as Real
import qualified System.IO.Temp                as Real
import qualified System.Process                as Real
import           System.Exit

run :: Machine a -> IO a
run (ListDirectory fp f             ) = f <$> Real.listDirectory fp
run (CreateDirectoryIfMissing p fp x) = do
    Real.createDirectoryIfMissing p fp
    return x
run (CreateTempDirectory fp f) = do
    t <- Real.createTempDirectory fp "btrfs-backup-sync-temp"
    return $ f t
run (RenameDirectory src dst x) = do
    Real.renameDirectory src dst
    return x
run (CopyFile src dst x) = do
    Real.copyFile src dst
    return x
run (ExecPipe p f) = do
    phs <- startPipe p
    ecs <- mapM Real.waitForProcess phs
    return $ f $ foldr combineExit ExitSuccess ecs
run (Crash r) = fail r

combineExit :: ExitCode -> ExitCode -> ExitCode
combineExit ExitSuccess       x = x
combineExit f@(ExitFailure _) _ = f

toRealProcess :: Process -> Real.CreateProcess
toRealProcess p = Real.proc (cmd p) (args p)

startPipe :: Pipe -> IO [Real.ProcessHandle]
startPipe = go id . map toRealProcess
  where
    go _   []  = return []
    go inH [p] = do
        (_, _, _, ph) <- Real.createProcess $ inH p
        return [ph]
    go inH (p : ps) = do
        (_, Just stdout, _, ph) <- Real.createProcess . inH $ p
            { Real.std_out = Real.CreatePipe
            }
        phs <- go (\p' -> p' { Real.std_in = Real.UseHandle stdout }) ps
        return $ ph : phs
