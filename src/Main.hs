module Main where

import           System.FilePath
import           System.Exit                              ( ExitCode
                                                              ( ExitSuccess
                                                              )
                                                          )
import           Data.Map                                 ( Map )
import qualified Data.Map                      as Map
import           Control.Monad                            ( guard
                                                          , forM_
                                                          , filterM
                                                          )
import           Machine
import qualified DryRunMachine                 as Fake
import qualified RealMachine                   as Real
import           System.Environment                       ( getArgs )

main :: IO ()
main = do
    [rf, src, dst] <- getArgs
    mainArgs rf src dst

mainArgs :: String -> FilePath -> FilePath -> IO ()
mainArgs rf src dst = case rf of
    "dry-run" -> eval Fake.dryRun $ sync src dst
    "real"    -> eval Real.run $ sync src dst
    _         -> fail "invalid method"

sync :: FilePath -> FilePath -> MachineM ()
sync src dst = do
    srcs <- filterM validSnapshot =<< map (src </>) <$> listDirectory src
    dsts <- filterM validSnapshot =<< map (dst </>) <$> listDirectory dst
    let cds = candidates srcs dsts
    forM_ cds $ \(parent, srcvol) -> sendReceive parent srcvol dst

validSnapshot :: FilePath -> MachineM Bool
validSnapshot fp = do
    contents <- listDirectory fp
    return $ elem "snapshot" contents && elem "info.xml" contents

sendReceive :: Maybe FilePath -> FilePath -> FilePath -> MachineM ()
sendReceive mparent source parentdir = do
    let dstdir = parentdir </> takeFileName source
    createDirectoryIfMissing False $ dstdir
    ExitSuccess <- execPipe [send mparent source, receive dstdir]
    copyFile (source </> "info.xml")
             (parentdir </> takeFileName source </> "info.xml")
    return ()

send :: Maybe FilePath -> FilePath -> Process
send mparent source = Process "btrfs" as
  where
    as =
        ["send", source </> "snapshot"]
            ++ maybe [] (\parent -> ["-p", parent </> "snapshot"]) mparent

receive :: FilePath -> Process
receive parentdir = Process "btrfs" ["receive", parentdir]

candidates :: [FilePath] -> [FilePath] -> [(Maybe FilePath, FilePath)]
candidates srcs dsts = do
    (i, src) <- Map.toList srcSet
    guard $ Map.notMember i dstSet
    let parent = snd <$> Map.lookupLT i srcSet
    return (parent, src)
  where
    srcSet, dstSet :: Map Int FilePath
    srcSet = Map.fromList
        [ (i, src)
        | src    <- srcs
        , Just i <- return $ maybeRead $ takeFileName src
        ]
    dstSet = Map.fromList
        [ (i, dst)
        | dst    <- dsts
        , Just i <- return $ maybeRead $ takeFileName dst
        ]

maybeRead :: Read a => String -> Maybe a
maybeRead s = case reads s of
    [(x, "")] -> Just x
    _         -> Nothing
