module Main (main) where

import HomesMap.Api.Server (runServer)

main :: IO ()
main = do
  putStrLn "homes-map-hs API listening on http://localhost:8080"
  runServer 8080
