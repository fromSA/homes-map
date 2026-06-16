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

type API =
  "health" :> Get '[JSON] HealthResponse
    :<|> "properties" :> Get '[JSON] [Property]
    :<|> "properties" :> Capture "id" Text :> "flow-rates" :> Get '[JSON] FlowRates

type HealthResponse = [(Text, Text)]

api :: Proxy API
api = Proxy

server :: Server API
server = healthHandler :<|> propertiesHandler :<|> flowRatesHandler
  where
    healthHandler :: Handler HealthResponse
    healthHandler = pure [("status", "ok"), ("service", "homes-map-hs")]

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
runServer port = run port app
