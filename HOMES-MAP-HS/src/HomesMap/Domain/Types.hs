{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module HomesMap.Domain.Types
  ( PropertyType (..),
    PartyRole (..),
    ContractStatus (..),
    PaymentStatus (..),
    MaintenanceStatus (..),
    OwnershipType (..),
    Money (..),
    Address (..),
    Property (..),
    Unit (..),
    Person (..),
    Ownership (..),
    Contract (..),
    Payment (..),
    MaintenanceRequest (..),
    EnergyReading (..),
    FlowRates (..)
  )
where

import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.Time (UTCTime)
import GHC.Generics (Generic)

data PropertyType = House | Apartment | Hybel | Studio | Room | Commercial
  deriving (Show, Eq, Generic)

instance ToJSON PropertyType
instance FromJSON PropertyType

data PartyRole = Tenant | Landlord | Bank | Agent
  deriving (Show, Eq, Generic)

instance ToJSON PartyRole
instance FromJSON PartyRole

data ContractStatus = Draft | Active | Expired | Terminated
  deriving (Show, Eq, Generic)

instance ToJSON ContractStatus
instance FromJSON ContractStatus

data PaymentStatus = Pending | Completed | Failed | Refunded
  deriving (Show, Eq, Generic)

instance ToJSON PaymentStatus
instance FromJSON PaymentStatus

data MaintenanceStatus = Open | InProgress | Resolved | Closed
  deriving (Show, Eq, Generic)

instance ToJSON MaintenanceStatus
instance FromJSON MaintenanceStatus

data OwnershipType = Freehold | Leasehold | Mortgage
  deriving (Show, Eq, Generic)

instance ToJSON OwnershipType
instance FromJSON OwnershipType

data Money = Money
  { amount :: Double,
    currency :: Text
  }
  deriving (Show, Eq, Generic)

instance ToJSON Money
instance FromJSON Money

data Address = Address
  { street :: Text,
    city :: Text,
    postalCode :: Text,
    country :: Text
  }
  deriving (Show, Eq, Generic)

instance ToJSON Address
instance FromJSON Address

data Unit = Unit
  { unitId :: Text,
    propertyId :: Text,
    label :: Text,
    areaM2 :: Double,
    floor :: Maybe Int,
    bedroomCount :: Int
  }
  deriving (Show, Eq, Generic)

instance ToJSON Unit
instance FromJSON Unit

data Property = Property
  { propertyKey :: Text,
    name :: Text,
    address :: Address,
    propertyType :: PropertyType,
    totalAreaM2 :: Double,
    units :: [Unit],
    energyRating :: Maybe Text
  }
  deriving (Show, Eq, Generic)

instance ToJSON Property
instance FromJSON Property

data Person = Person
  { personId :: Text,
    firstName :: Text,
    lastName :: Text,
    email :: Text,
    role :: PartyRole
  }
  deriving (Show, Eq, Generic)

instance ToJSON Person
instance FromJSON Person

data Ownership = Ownership
  { ownershipId :: Text,
    ownershipPropertyId :: Text,
    ownerId :: Text,
    ownershipType :: OwnershipType,
    sharePercent :: Double,
    acquiredAt :: UTCTime,
    releasedAt :: Maybe UTCTime
  }
  deriving (Show, Eq, Generic)

instance ToJSON Ownership
instance FromJSON Ownership

data Contract = Contract
  { contractId :: Text,
    contractPropertyId :: Text,
    contractUnitId :: Maybe Text,
    landlordId :: Text,
    tenantId :: Text,
    bankId :: Maybe Text,
    status :: ContractStatus,
    rentAmount :: Money,
    depositAmount :: Money,
    startDate :: UTCTime,
    endDate :: Maybe UTCTime,
    noticePeriodDays :: Int
  }
  deriving (Show, Eq, Generic)

instance ToJSON Contract
instance FromJSON Contract

data Payment = Payment
  { paymentId :: Text,
    paymentContractId :: Text,
    fromPartyId :: Text,
    toPartyId :: Text,
    paymentAmount :: Money,
    paymentStatus :: PaymentStatus,
    description :: Text,
    dueDate :: UTCTime,
    paidAt :: Maybe UTCTime
  }
  deriving (Show, Eq, Generic)

instance ToJSON Payment
instance FromJSON Payment

data MaintenanceRequest = MaintenanceRequest
  { maintenanceId :: Text,
    maintenancePropertyId :: Text,
    maintenanceUnitId :: Maybe Text,
    requestedById :: Text,
    assignedToId :: Maybe Text,
    maintenanceStatus :: MaintenanceStatus,
    title :: Text,
    details :: Text,
    createdAt :: UTCTime,
    resolvedAt :: Maybe UTCTime
  }
  deriving (Show, Eq, Generic)

instance ToJSON MaintenanceRequest
instance FromJSON MaintenanceRequest

data EnergyReading = EnergyReading
  { energyReadingId :: Text,
    energyPropertyId :: Text,
    readingKWh :: Double,
    readingDate :: UTCTime,
    recordedById :: Text
  }
  deriving (Show, Eq, Generic)

instance ToJSON EnergyReading
instance FromJSON EnergyReading

data FlowRates = FlowRates
  { flowRatesPropertyId :: Text,
    rentPaymentOnTimePct :: Double,
    avgMaintenanceResolutionHours :: Double,
    energyEfficiencyKWhPerM2 :: Maybe Double
  }
  deriving (Show, Eq, Generic)

instance ToJSON FlowRates
instance FromJSON FlowRates
