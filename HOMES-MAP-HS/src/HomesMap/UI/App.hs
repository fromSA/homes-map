{-# LANGUAGE OverloadedStrings #-}

module HomesMap.UI.App (startUI) where

import Graphics.UI.Threepenny.Core
import Graphics.UI.Threepenny.Elements
import Graphics.UI.Threepenny.Attributes
import Control.Monad (void)

-- | Start the UI server on the specified port, connecting to the API on apiPort
startUI :: Int -> Int -> IO ()
startUI uiPort apiPort = do
  startGUI defaultConfig { jsPort = Just uiPort }
    (setupUI apiPort)

-- | Setup the main UI window
setupUI :: Int -> Window -> UI ()
setupUI apiPort w = do
  _ <- return w # set title "homes-map-hs - Dashboard"
  
  body <- getBody w
  
  -- Create header
  header <- h1 #+ [string "homes-map-hs Dashboard"]
  subtitle <- p #+ [string "A Haskell-based property and flow rates system"]
  
  -- Create info box
  info <- p #+ [string ("API Server: http://localhost:" ++ show apiPort)]
  
  -- Create footer
  footer <- p #+ [string "Built with Haskell, Servant, and threepenny-gui"]
  
  -- Layout
  void $ element body #+
    [ element header
    , element subtitle
    , element info
    , hr
    , string "This is a threepenny-gui frontend. Connect to the API at the URL above."
    , element footer
    ]
