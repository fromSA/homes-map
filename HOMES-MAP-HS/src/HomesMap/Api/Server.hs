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
import Network.Wai.Handler.Warp (run)
import Servant

type PropertyApi =
  "properties" :> Get '[JSON] [Property]
    :<|> "properties" :> Capture "id" Text :> "flow-rates" :> Get '[JSON] FlowRates

type API =
  "health" :> Get '[JSON] HealthResponse
    :<|> "api" :> PropertyApi

type HealthResponse = [(Text, Text)]

api :: Proxy API
api = Proxy

server :: Server API
server = healthHandler :<|> propertyApiServer
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

app :: Application
app = serve api server

runServer :: Int -> IO ()
runServer port = do
  putStrLn $ "homes-map-hs API listening on http://localhost:" ++ show port
  run port app
