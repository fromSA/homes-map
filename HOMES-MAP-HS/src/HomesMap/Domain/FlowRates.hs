{-# LANGUAGE OverloadedStrings #-}

module HomesMap.Domain.FlowRates
  ( calculateFlowRates,
    onTimePaymentPct,
    avgResolutionHours,
    latestEnergyEfficiency
  )
where

import Data.Text (Text)
import Data.Time (diffUTCTime)
import HomesMap.Domain.Types

calculateFlowRates :: Text -> Property -> [Payment] -> [MaintenanceRequest] -> [EnergyReading] -> FlowRates
calculateFlowRates pid property payments maintenanceRequests readings =
  FlowRates
    { flowRatesPropertyId = pid,
      rentPaymentOnTimePct = onTimePaymentPct payments,
      avgMaintenanceResolutionHours = avgResolutionHours maintenanceRequests,
      energyEfficiencyKWhPerM2 = latestEnergyEfficiency property readings
    }

onTimePaymentPct :: [Payment] -> Double
onTimePaymentPct payments =
  let completed = filter (\p -> paymentStatus p == Completed && paidAt p /= Nothing) payments
      onTime = filter isOnTime completed
      totalCount = length completed
      onTimeCount = length onTime
   in if totalCount == 0 then 0 else (fromIntegral onTimeCount / fromIntegral totalCount) * 100
  where
    isOnTime p =
      case paidAt p of
        Nothing -> False
        Just paid -> paid <= dueDate p

avgResolutionHours :: [MaintenanceRequest] -> Double
avgResolutionHours requests =
  let resolved = filter (\r -> resolvedAt r /= Nothing) requests
      diffs = map resolutionHours resolved
      totalCount = length diffs
   in if totalCount == 0 then 0 else sum diffs / fromIntegral totalCount
  where
    resolutionHours req =
      case resolvedAt req of
        Nothing -> 0
        Just done -> realToFrac (diffUTCTime done (createdAt req)) / 3600

latestEnergyEfficiency :: Property -> [EnergyReading] -> Maybe Double
latestEnergyEfficiency property readings =
  case readings of
    [] -> Nothing
    _ ->
      let latest = foldr1 newest readings
          area = totalAreaM2 property
       in if area <= 0 then Nothing else Just (readingKWh latest / area)
  where
    newest a b = if readingDate a >= readingDate b then a else b
