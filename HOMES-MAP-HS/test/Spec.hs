{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import HomesMap.Domain.FlowRates
import HomesMap.Domain.SampleData
import Test.Hspec

main :: IO ()
main = hspec $ do
  describe "Flow rate calculations" $ do
    it "computes on-time payment percentage" $ do
      onTimePaymentPct samplePayments `shouldBe` 50.0

    it "computes average maintenance resolution hours" $ do
      avgResolutionHours sampleMaintenance `shouldBe` 30.0

    it "computes latest energy efficiency" $ do
      case findPropertyById "property-1" of
        Nothing -> expectationFailure "Expected sample property"
        Just p -> latestEnergyEfficiency p sampleEnergyReadings `shouldBe` Just (240.0 / 65.0)
