import { useQuery } from "@tanstack/react-query";
import type { Contract } from "@homes-map/shared";

async function fetchContracts(): Promise<{ data: Contract[] }> {
  const res = await fetch("/api/contracts");
  if (!res.ok) throw new Error("Failed");
  return res.json();
}

const statusColor: Record<string, string> = {
  active: "bg-green-100 text-green-700",
  draft: "bg-yellow-100 text-yellow-700",
  expired: "bg-gray-100 text-gray-600",
  terminated: "bg-red-100 text-red-700",
};

export function ContractsPage() {
  const { data, isLoading } = useQuery({ queryKey: ["contracts"], queryFn: fetchContracts });

  if (isLoading) return <p className="text-gray-500">Loading contracts…</p>;

  return (
    <div>
      <h1 className="text-2xl font-semibold mb-4">Contracts</h1>
      <div className="space-y-3">
        {data?.data.map((c) => (
          <div key={c.id} className="bg-white border border-gray-200 rounded-xl p-4 flex items-center justify-between">
            <div>
              <p className="font-medium">{c.rentAmount.amount} {c.rentAmount.currency} / mo</p>
              <p className="text-sm text-gray-500">From {new Date(c.startDate).toLocaleDateString()}</p>
            </div>
            <span className={`text-xs font-semibold px-2 py-0.5 rounded ${statusColor[c.status] ?? ""}`}>
              {c.status}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
