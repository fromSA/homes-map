module Main (main) where

import HomesMap.UI.App (startUI)

main :: IO ()
main = do
  putStrLn ""
  putStrLn "╭──────────────────────────────────────────────────╮"
  putStrLn "│         homes-map-hs UI (threepenny-gui)        │"
  putStrLn "╰──────────────────────────────────────────────────╯"
  putStrLn ""
  putStrLn "Make sure the API server is running on port 8080:"
  putStrLn "  cabal run homes-map-hs"
  putStrLn ""
  putStrLn "Starting UI on http://localhost:8000"
  putStrLn "A browser window will open automatically."
  putStrLn ""
  
  -- Start UI on port 8000, connecting to API on port 8080
  startUI 8000 8080
