import { useQuery } from "@tanstack/react-query";
import { useParams } from "react-router-dom";
import type { Property, FlowRates } from "@homes-map/shared";

async function fetchProperty(id: string): Promise<{ data: Property }> {
  const res = await fetch(`/api/properties/${id}`);
  if (!res.ok) throw new Error("Not found");
  return res.json();
}

async function fetchFlowRates(id: string): Promise<{ data: FlowRates }> {
  const res = await fetch(`/api/properties/${id}/flow-rates`);
  if (!res.ok) throw new Error("Failed");
  return res.json();
}

export function PropertyDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data: propData } = useQuery({ queryKey: ["property", id], queryFn: () => fetchProperty(id!) });
  const { data: ratesData } = useQuery({ queryKey: ["flow-rates", id], queryFn: () => fetchFlowRates(id!) });

  const property = propData?.data;
  const rates = ratesData?.data;

  if (!property) return <p className="text-gray-500">Loading…</p>;

  return (
    <div className="max-w-3xl space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">{property.name}</h1>
        <p className="text-gray-500">{property.address.street}, {property.address.city} {property.address.postalCode}</p>
      </div>

      {rates && (
        <section className="bg-white border border-gray-200 rounded-xl p-4">
          <h2 className="font-semibold mb-3">Flow Rates</h2>
          <dl className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <dt className="text-gray-500">On-time payments</dt>
              <dd className="font-medium">{rates.rentPaymentOnTimePct.toFixed(0)}%</dd>
            </div>
            <div>
              <dt className="text-gray-500">Avg. maintenance resolution</dt>
              <dd className="font-medium">{rates.avgMaintenanceResolutionHours.toFixed(1)} h</dd>
            </div>
            <div>
              <dt className="text-gray-500">Energy efficiency</dt>
              <dd className="font-medium">
                {rates.energyEfficiencyKWhPerM2 != null ? `${rates.energyEfficiencyKWhPerM2.toFixed(1)} kWh/m²` : "—"}
              </dd>
            </div>
          </dl>
        </section>
      )}
    </div>
  );
}
