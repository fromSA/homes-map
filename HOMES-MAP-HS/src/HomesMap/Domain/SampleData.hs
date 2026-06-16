{-# LANGUAGE OverloadedStrings #-}

module HomesMap.Domain.SampleData
  ( sampleProperties,
    sampleContracts,
    samplePayments,
    sampleMaintenance,
    sampleEnergyReadings,
    findPropertyById
  )
where

import Data.Text (Text)
import Data.Time.Calendar (fromGregorian)
import Data.Time.Clock (UTCTime (..), secondsToDiffTime)
import HomesMap.Domain.Types

mkUtc :: Integer -> Int -> Int -> Int -> Int -> Int -> UTCTime
mkUtc y m d hh mm ss =
  UTCTime (fromGregorian y m d) (secondsToDiffTime (fromIntegral (hh * 3600 + mm * 60 + ss)))

sampleProperties :: [Property]
sampleProperties =
  [ Property
      { propertyKey = "property-1",
        name = "Markveien 12",
        address = Address "Markveien 12" "Oslo" "0554" "NO",
        propertyType = Apartment,
        totalAreaM2 = 65.0,
        units = [Unit "unit-1" "property-1" "Leilighet 2B" 65.0 (Just 2) 2],
        energyRating = Just "C"
      }
  ]

sampleContracts :: [Contract]
sampleContracts =
  [ Contract
      { contractId = "contract-1",
        contractPropertyId = "property-1",
        contractUnitId = Just "unit-1",
        landlordId = "person-landlord-1",
        tenantId = "person-tenant-1",
        bankId = Just "person-bank-1",
        status = Active,
        rentAmount = Money 12500 "NOK",
        depositAmount = Money 37500 "NOK",
        startDate = mkUtc 2025 1 1 0 0 0,
        endDate = Nothing,
        noticePeriodDays = 30
      }
  ]

samplePayments :: [Payment]
samplePayments =
  [ Payment
      { paymentId = "payment-1",
        paymentContractId = "contract-1",
        fromPartyId = "person-tenant-1",
        toPartyId = "person-landlord-1",
        paymentAmount = Money 12500 "NOK",
        paymentStatus = Completed,
        description = "January rent",
        dueDate = mkUtc 2026 1 5 0 0 0,
        paidAt = Just (mkUtc 2026 1 4 9 0 0)
      },
    Payment
      { paymentId = "payment-2",
        paymentContractId = "contract-1",
        fromPartyId = "person-tenant-1",
        toPartyId = "person-landlord-1",
        paymentAmount = Money 12500 "NOK",
        paymentStatus = Completed,
        description = "February rent",
        dueDate = mkUtc 2026 2 5 0 0 0,
        paidAt = Just (mkUtc 2026 2 8 9 0 0)
      }
  ]

sampleMaintenance :: [MaintenanceRequest]
sampleMaintenance =
  [ MaintenanceRequest
      { maintenanceId = "maintenance-1",
        maintenancePropertyId = "property-1",
        maintenanceUnitId = Just "unit-1",
        requestedById = "person-tenant-1",
        assignedToId = Just "person-landlord-1",
        maintenanceStatus = Resolved,
        title = "Kitchen leak",
        details = "Leak under sink",
        createdAt = mkUtc 2026 3 1 12 0 0,
        resolvedAt = Just (mkUtc 2026 3 2 18 0 0)
      }
  ]

sampleEnergyReadings :: [EnergyReading]
sampleEnergyReadings =
  [ EnergyReading
      { energyReadingId = "energy-1",
        energyPropertyId = "property-1",
        readingKWh = 240.0,
        readingDate = mkUtc 2026 3 31 0 0 0,
        recordedById = "person-landlord-1"
      }
  ]

findPropertyById :: Text -> Maybe Property
findPropertyById pid =
  case filter (\p -> propertyKey p == pid) sampleProperties of
    [] -> Nothing
    (x : _) -> Just x
