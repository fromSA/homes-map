// ─── Enumerations ────────────────────────────────────────────────────────────

export type PropertyType = "house" | "apartment" | "hybel" | "studio" | "room" | "commercial";
export type PartyRole = "tenant" | "landlord" | "bank" | "agent";
export type ContractStatus = "draft" | "active" | "expired" | "terminated";
export type PaymentStatus = "pending" | "completed" | "failed" | "refunded";
export type MaintenanceStatus = "open" | "in_progress" | "resolved" | "closed";
export type OwnershipType = "freehold" | "leasehold" | "mortgage";
export type FlowDirection = "inbound" | "outbound";

// ─── Stocks ───────────────────────────────────────────────────────────────────

export interface Property {
  id: string;
  name: string;
  address: Address;
  type: PropertyType;
  totalAreaM2: number;
  units: Unit[];
  energyRating?: string;       // EU energy class A–G
  createdAt: Date;
  updatedAt: Date;
}

export interface Unit {
  id: string;
  propertyId: string;
  label: string;               // "Unit 2B", "Hybel 1", etc.
  areaM2: number;
  floor?: number;
  bedroomCount: number;
}

export interface Address {
  street: string;
  city: string;
  postalCode: string;
  country: string;
  coordinates?: { lat: number; lng: number };
}

export interface Person {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  role: PartyRole;
  createdAt: Date;
}

export interface Ownership {
  id: string;
  propertyId: string;
  ownerId: string;
  type: OwnershipType;
  sharePercent: number;        // 0–100
  acquiredAt: Date;
  releasedAt?: Date;
}

// ─── Flows ───────────────────────────────────────────────────────────────────

export interface Contract {
  id: string;
  propertyId: string;
  unitId?: string;
  landlordId: string;
  tenantId: string;
  bankId?: string;
  status: ContractStatus;
  rentAmount: Money;
  depositAmount: Money;
  startDate: Date;
  endDate?: Date;
  noticePeriodDays: number;
  documents: Document[];
  createdAt: Date;
}

export interface Payment {
  id: string;
  contractId: string;
  fromPartyId: string;
  toPartyId: string;
  amount: Money;
  direction: FlowDirection;
  status: PaymentStatus;
  description: string;
  dueDate: Date;
  paidAt?: Date;
  createdAt: Date;
}

export interface MaintenanceRequest {
  id: string;
  propertyId: string;
  unitId?: string;
  requestedById: string;
  assignedToId?: string;
  status: MaintenanceStatus;
  title: string;
  description: string;
  priority: "low" | "medium" | "high" | "urgent";
  attachments: string[];
  createdAt: Date;
  resolvedAt?: Date;
}

export interface EnergyReading {
  id: string;
  propertyId: string;
  unitId?: string;
  readingKWh: number;
  readingDate: Date;
  recordedById: string;
}

export interface Document {
  id: string;
  name: string;
  url: string;
  mimeType: string;
  uploadedById: string;
  uploadedAt: Date;
}

// ─── Flow Rates ───────────────────────────────────────────────────────────────

export interface FlowRates {
  propertyId: string;
  paymentCadenceDays: number;         // e.g. 30 = monthly
  avgOwnershipTransferDays: number;   // days from offer to title
  avgMaintenanceResolutionHours: number;
  energyEfficiencyKWhPerM2: number;
  rentPaymentOnTimePct: number;       // 0–100
}

// ─── Shared primitives ────────────────────────────────────────────────────────

export interface Money {
  amount: number;
  currency: string;                   // ISO 4217, e.g. "NOK", "EUR"
}

// ─── API response envelope ────────────────────────────────────────────────────

export interface ApiResponse<T> {
  data: T;
  meta?: Record<string, unknown>;
}

export interface ApiError {
  code: string;
  message: string;
  details?: unknown;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  meta: {
    total: number;
    page: number;
    pageSize: number;
  };
}
