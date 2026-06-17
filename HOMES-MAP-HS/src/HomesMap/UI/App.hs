{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ScopedTypeVariables #-}

module HomesMap.UI.App (startUI) where

import qualified Data.Text as T
import Data.Aeson (FromJSON, ToJSON, decode, object, (.=))
import GHC.Generics (Generic)
import Control.Monad (void, forM_)
import Control.Exception (try, SomeException)
import Graphics.UI.Threepenny.Core
import Graphics.UI.Threepenny.Elements hiding (div, name, address, span)
import qualified Graphics.UI.Threepenny.Elements as El
import Graphics.UI.Threepenny.Attributes hiding (name)
import qualified Graphics.UI.Threepenny.Events as Events
import Network.HTTP.Client (newManager, defaultManagerSettings, parseRequest, httpLbs, responseBody)

-- | Property type matching API
data Property = Property
  { propertyKey :: T.Text
  , name :: T.Text
  , address :: Address
  , totalAreaM2 :: Double
  , propertyType :: T.Text
  } deriving (Show, Generic)

instance FromJSON Property
instance ToJSON Property

data Address = Address
  { street :: T.Text
  , city :: T.Text
  } deriving (Show, Generic)

instance FromJSON Address
instance ToJSON Address

-- | Flow rates type matching API
data FlowRates = FlowRates
  { rentPaymentOnTimePct :: Double
  , avgMaintenanceResolutionHours :: Double
  , energyEfficiencyKWhPerM2 :: Maybe Double
  } deriving (Show, Generic)

instance FromJSON FlowRates
instance ToJSON FlowRates

-- | Start the UI server
startUI :: Int -> Int -> IO ()
startUI uiPort apiPort = do
  startGUI defaultConfig { jsPort = Just uiPort }
    (setupUI apiPort)

-- | Setup the main UI window with styling
setupUI :: Int -> Window -> UI ()
setupUI apiPort w = do
  _ <- return w # set title "homes-map-hs - Dashboard"
  
  body <- getBody w
  
  -- Inject CSS styles
  void $ element body # set (attr "style") "font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background: #f5f7fa;"
  
  -- Create main container
  mainContainer <- El.div # set (attr "class") "container"
    # set (attr "style") "max-width: 1200px; margin: 0 auto; padding: 2rem;"
  
  -- Header section
  headerDiv <- El.div
    # set (attr "style") "background: linear-gradient(135deg, #0d7a5f 0%, #0b9f6f 100%); color: white; padding: 2rem; border-radius: 16px; margin-bottom: 2rem;"
  
  eyebrow <- El.span #+ [string "HOMES-MAP-HS"]
    # set (attr "style") "letter-spacing: 0.12em; text-transform: uppercase; font-size: 0.85rem; font-weight: 700; display: block; margin-bottom: 0.5rem; opacity: 0.9;"
  
  headerTitle <- h1 #+ [string "Simplify Tenant, Landlord, and Bank Collaboration"]
    # set (attr "style") "margin: 0 0 0.5rem 0; font-size: 2rem; line-height: 1.2;"
  
  headerSubtitle <- p #+ [string "Live dashboard of properties and flow rates"]
    # set (attr "style") "margin: 0; font-size: 1rem; opacity: 0.95;"
  
  void $ element headerDiv #+ [element eyebrow, element headerTitle, element headerSubtitle]
  
  -- Properties section
  propertiesSection <- El.div
    # set (attr "style") "margin-bottom: 2rem;"
  
  sectionHead <- El.div
    # set (attr "style") "display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem;"
  
  propertiesHeading <- h2 #+ [string "Properties"]
    # set (attr "style") "margin: 0; font-size: 1.5rem; color: #1e293b;"
  
  refreshBtn <- button #+ [string "↻ Refresh"]
    # set (attr "class") "btn-primary"
    # set (attr "style") "border: none; background: linear-gradient(90deg, #0d7a5f, #0b9f6f); color: white; padding: 0.6rem 1rem; border-radius: 8px; cursor: pointer; font-weight: 600; font-size: 0.9rem;"
  
  void $ element sectionHead #+ [element propertiesHeading, element refreshBtn]
  
  propertiesGrid <- El.div
    # set (attr "style") "display: grid; gap: 1rem; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));"
  
  void $ element propertiesSection #+ [element sectionHead, element propertiesGrid]
  
  -- Flow rates section
  flowRatesSection <- El.div
    # set (attr "style") "margin-bottom: 2rem;"
  
  flowRatesHeading <- h2 #+ [string "Flow Rates"]
    # set (attr "style") "margin: 0 0 1rem 0; font-size: 1.5rem; color: #1e293b;"
  
  flowRatesContainer <- El.div
    # set (attr "style") "border: 1px solid #dbe4dd; border-radius: 16px; padding: 1.5rem; background: white; box-shadow: 0 2px 8px rgba(15, 23, 42, 0.08);"
    # set (attr "id") "flow-rates"
  
  void $ element flowRatesSection #+ [element flowRatesHeading, element flowRatesContainer]
  
  -- Assemble main layout
  void $ element mainContainer #+
    [ element headerDiv
    , element propertiesSection
    , element flowRatesSection
    ]
  
  void $ element body #+ [element mainContainer]
  
  -- Fetch and display properties
  on Events.click refreshBtn $ \_ -> do
    loadProperties apiPort propertiesGrid flowRatesContainer
  
  -- Load initial data
  loadProperties apiPort propertiesGrid flowRatesContainer

-- | Fetch properties from API
loadProperties :: Int -> Element -> Element -> UI ()
loadProperties apiPort propertiesGrid flowRatesContainer = do
  let apiUrl = "http://localhost:" ++ show apiPort ++ "/api/properties"
  
  result <- liftIO $ try $ do
    manager <- newManager defaultManagerSettings
    req <- parseRequest apiUrl
    response <- httpLbs req manager
    pure (decode (responseBody response) :: Maybe [Property])
  
  case result of
    Left (_ :: SomeException) -> do
      errorMsg <- p #+ [string "Error loading properties. Is the API running?"]
        # set (attr "style") "color: #dc2626; font-weight: 600; padding: 1rem; background: #fee2e2; border-radius: 8px;"
      void $ element propertiesGrid # set children [errorMsg]
    Right Nothing -> do
      errorMsg <- p #+ [string "Failed to parse properties from API"]
        # set (attr "style") "color: #dc2626; font-weight: 600; padding: 1rem; background: #fee2e2; border-radius: 8px;"
      void $ element propertiesGrid # set children [errorMsg]
    Right (Just []) -> do
      emptyMsg <- p #+ [string "No properties found"]
        # set (attr "style") "color: #0d7a5f; font-weight: 600; padding: 1rem; background: #dcfce7; border-radius: 8px;"
      void $ element propertiesGrid # set children [emptyMsg]
    Right (Just props) -> do
      void $ element propertiesGrid # set children []
      forM_ props $ \prop -> do
        card <- renderPropertyCard apiPort prop flowRatesContainer
        void $ element propertiesGrid #+ [element card]

-- | Render a single property card
renderPropertyCard :: Int -> Property -> Element -> UI Element
renderPropertyCard apiPort prop flowRatesContainer = do
  card <- El.div
    # set (attr "style") "border: 1px solid #dbe4dd; border-radius: 16px; padding: 1.5rem; background: white; box-shadow: 0 2px 8px rgba(15, 23, 42, 0.08); transition: box-shadow 0.2s; cursor: pointer;"
  
  nameEl <- h3 #+ [string (T.unpack (name prop))]
    # set (attr "style") "margin: 0 0 0.5rem 0; font-size: 1.1rem; color: #1e293b;"
  
  addressEl <- p #+ [string (T.unpack (street (address prop) <> ", " <> city (address prop)))]
    # set (attr "style") "margin: 0.5rem 0; color: #64748b; font-size: 0.9rem;"
  
  areaEl <- p #+ [string ("Area: " ++ show (totalAreaM2 prop) ++ " m²")]
    # set (attr "style") "margin: 0.5rem 0; color: #64748b; font-size: 0.9rem; font-weight: 500;"
  
  btn <- button #+ [string "View Flow Rates"]
    # set (attr "style") "margin-top: 1rem; border: none; background: linear-gradient(90deg, #0d7a5f, #0b9f6f); color: white; padding: 0.6rem 1rem; border-radius: 8px; cursor: pointer; font-weight: 600; width: 100%;"
  
  on Events.click btn $ \_ -> 
    loadFlowRates apiPort (propertyKey prop) flowRatesContainer
  
  void $ element card #+
    [ element nameEl
    , element addressEl
    , element areaEl
    , element btn
    ]
  
  pure card

-- | Load and display flow rates for a property
loadFlowRates :: Int -> T.Text -> Element -> UI ()
loadFlowRates apiPort propKey flowRatesContainer = do
  let apiUrl = "http://localhost:" ++ show apiPort ++ "/api/properties/" ++ T.unpack propKey ++ "/flow-rates"
  
  result <- liftIO $ try $ do
    manager <- newManager defaultManagerSettings
    req <- parseRequest apiUrl
    response <- httpLbs req manager
    pure (decode (responseBody response) :: Maybe FlowRates)
  
  case result of
    Left (_ :: SomeException) -> do
      errorMsg <- p #+ [string "Error loading flow rates"]
        # set (attr "style") "color: #dc2626; font-weight: 600; padding: 1rem; background: #fee2e2; border-radius: 8px;"
      void $ element flowRatesContainer # set children [errorMsg]
    Right Nothing -> do
      errorMsg <- p #+ [string "Failed to parse flow rates"]
        # set (attr "style") "color: #dc2626; font-weight: 600; padding: 1rem; background: #fee2e2; border-radius: 8px;"
      void $ element flowRatesContainer # set children [errorMsg]
    Right (Just rates) -> do
      void $ element flowRatesContainer # set children []
      
      titleEl <- h3 #+ [string (T.unpack ("Flow Rates - " <> propKey))]
        # set (attr "style") "margin: 0 0 1.5rem 0; font-size: 1.3rem; color: #1e293b;"
      
      let paymentPct = rentPaymentOnTimePct rates
          paymentStatus = if paymentPct < 70 then "low" else "good"
          paymentBg = if paymentPct < 70 then "#fef3c7" else "#dcfce7"
          paymentBorder = if paymentPct < 70 then "#fcd34d" else "#86efac"
      
      paymentDiv <- El.div
        # set (attr "style") ("border-left: 4px solid " ++ paymentBorder ++ "; padding: 1rem; background: " ++ paymentBg ++ "; border-radius: 8px; margin-bottom: 1rem;")
      paymentLabel <- El.div #+ [string "On-time Payment %"]
        # set (attr "style") "color: #64748b; font-size: 0.9rem; margin-bottom: 0.5rem;"
      paymentValue <- El.div #+ [string (formatPercent paymentPct)]
        # set (attr "style") "font-size: 1.8rem; font-weight: 700; color: #1e293b;"
      void $ element paymentDiv #+ [element paymentLabel, element paymentValue]
      
      let maintenanceHours = avgMaintenanceResolutionHours rates
          maintenanceBg = if maintenanceHours > 48 then "#fef3c7" else "#dcfce7"
          maintenanceBorder = if maintenanceHours > 48 then "#fcd34d" else "#86efac"
      
      maintenanceDiv <- El.div
        # set (attr "style") ("border-left: 4px solid " ++ maintenanceBorder ++ "; padding: 1rem; background: " ++ maintenanceBg ++ "; border-radius: 8px; margin-bottom: 1rem;")
      maintenanceLabel <- El.div #+ [string "Avg Maintenance Resolution (h)"]
        # set (attr "style") "color: #64748b; font-size: 0.9rem; margin-bottom: 0.5rem;"
      maintenanceValue <- El.div #+ [string (formatHours maintenanceHours)]
        # set (attr "style") "font-size: 1.8rem; font-weight: 700; color: #1e293b;"
      void $ element maintenanceDiv #+ [element maintenanceLabel, element maintenanceValue]
      
      efficiencyDiv <- El.div
        # set (attr "style") "border-left: 4px solid #c7d2fe; padding: 1rem; background: #eef2ff; border-radius: 8px;"
      efficiencyLabel <- El.div #+ [string "Energy Efficiency (kWh/m²)"]
        # set (attr "style") "color: #64748b; font-size: 0.9rem; margin-bottom: 0.5rem;"
      efficiencyValue <- El.div #+ [string (formatEfficiency (energyEfficiencyKWhPerM2 rates))]
        # set (attr "style") "font-size: 1.8rem; font-weight: 700; color: #1e293b;"
      void $ element efficiencyDiv #+ [element efficiencyLabel, element efficiencyValue]
      
      void $ element flowRatesContainer #+
        [ element titleEl
        , element paymentDiv
        , element maintenanceDiv
        , element efficiencyDiv
        ]

-- | Helper functions for formatting
formatPercent :: Double -> String
formatPercent v = show (round v :: Int) ++ "%"

formatHours :: Double -> String
formatHours v = show (fromIntegral (round (v * 10) :: Int) / 10 :: Double) ++ " h"

formatEfficiency :: Maybe Double -> String
formatEfficiency Nothing = "-"
formatEfficiency (Just v) = show (fromIntegral (round (v * 100) :: Int) / 100 :: Double)
