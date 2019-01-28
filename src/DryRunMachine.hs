module DryRunMachine
    ( dryRun
    )
where

import           Machine
import qualified System.Directory              as Real
import           System.Exit
import           Data.List                                ( intercalate )
import           System.FilePath                          ( (</>) )

dryRun :: Machine (IO a) -> IO a
dryRun (ListDirectory fp f             ) = f =<< Real.listDirectory fp
dryRun (CreateDirectoryIfMissing p fp x) = do
    putStrLn $ unwords $ ["mkdir"] ++ [ "-p" | p ] ++ [fp]
    x
dryRun (CreateTempDirectory fp f) = do
    let tmp = fp </> "fresh_temp_dir"
    putStrLn $ unwords ["mkdir", tmp]
    f tmp
dryRun (RenameDirectory src dst x) = do
    putStrLn $ unwords ["mv", src, dst]
    x
dryRun (CopyFile src dst x) = do
    putStrLn $ unwords ["cp", src, dst]
    x
dryRun (ExecPipe p f) = do
    putStrLn $ renderPipe p
    f ExitSuccess
dryRun (Crash r) = fail r

renderProcess :: Process -> String
renderProcess p = unwords $ cmd p : args p

renderPipe :: Pipe -> String
renderPipe = intercalate " | " . map renderProcess
