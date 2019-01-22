module DryRunMachine
    ( dryRun
    )
where

import           Machine
import qualified System.Directory              as Real
import           System.Exit
import           Data.List                                ( intercalate )

dryRun :: Machine a -> IO a
dryRun (ListDirectory fp f             ) = f <$> Real.listDirectory fp
dryRun (CreateDirectoryIfMissing p fp x) = do
    putStrLn $ unwords $ ["mkdir"] ++ [ "-p" | p ] ++ [fp]
    return x
dryRun (CopyFile src dst x) = do
    putStrLn $ unwords ["cp", src, dst]
    return x
dryRun (ExecPipe p f) = do
    putStrLn $ renderPipe p
    return $ f ExitSuccess
dryRun (Crash r) = fail r

renderProcess :: Process -> String
renderProcess p = unwords $ cmd p : args p

renderPipe :: Pipe -> String
renderPipe = intercalate " | " . map renderProcess
