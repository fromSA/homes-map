{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module HomesMap.Api.Server
  ( app,
    runServer
  )
where

import Data.Text (Text)
import HomesMap.Domain.FlowRates (calculateFlowRates)
import HomesMap.Domain.SampleData
import HomesMap.Domain.Types
import Network.Wai (Application, pathInfo, rawPathInfo)
import Network.Wai.Handler.Warp (run)
import Paths_homes_map_hs (getDataFileName)
import System.Directory (doesDirectoryExist, getCurrentDirectory)
import Servant
import System.FilePath (takeDirectory)

type PropertyApi =
  "properties" :> Get '[JSON] [Property]
    :<|> "properties" :> Capture "id" Text :> "flow-rates" :> Get '[JSON] FlowRates

type API =
  "health" :> Get '[JSON] HealthResponse
    :<|> "api" :> PropertyApi
    :<|> Raw

type HealthResponse = [(Text, Text)]

api :: Proxy API
api = Proxy

server :: FilePath -> Server API
server frontendDir = healthHandler :<|> propertyApiServer :<|> serveDirectoryWebApp frontendDir
  where
    healthHandler :: Handler HealthResponse
    healthHandler = pure [("status", "ok"), ("service", "homes-map-hs")]

    propertyApiServer :: Server PropertyApi
    propertyApiServer = propertiesHandler :<|> flowRatesHandler

    propertiesHandler :: Handler [Property]
    propertiesHandler = pure sampleProperties

    flowRatesHandler :: Text -> Handler FlowRates
    flowRatesHandler pid =
      case findPropertyById pid of
        Nothing -> throwError err404 {errBody = "Property not found"}
        Just p ->
          let rates = calculateFlowRates pid p samplePayments sampleMaintenance sampleEnergyReadings
           in pure rates

app :: FilePath -> Application
app frontendDir = rewriteRootToIndex (serve api (server frontendDir))

runServer :: Int -> IO ()
runServer port = do
  frontendDir <- resolveFrontendDir
  putStrLn ("Serving frontend from: " ++ frontendDir)
  run port (app frontendDir)

resolveFrontendDir :: IO FilePath
resolveFrontendDir = do
  indexPath <- getDataFileName "frontend/index.html"
  cwd <- getCurrentDirectory
  let candidates =
        [ takeDirectory indexPath,
          cwd ++ "/frontend",
          cwd ++ "/HOMES-MAP-HS/frontend",
          cwd ++ "/../HOMES-MAP-HS/frontend",
          cwd ++ "/../../HOMES-MAP-HS/frontend"
        ]
  pickFirstExisting candidates

pickFirstExisting :: [FilePath] -> IO FilePath
pickFirstExisting [] = pure "frontend"
pickFirstExisting (x : xs) = do
  exists <- doesDirectoryExist x
  if exists then pure x else pickFirstExisting xs

rewriteRootToIndex :: Application -> Application
rewriteRootToIndex inner req respond =
  if rawPathInfo req == "/"
    then inner req {rawPathInfo = "/index.html", pathInfo = ["index.html"]} respond
    else inner req respond
