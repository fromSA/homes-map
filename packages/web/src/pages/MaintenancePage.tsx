import { useQuery } from "@tanstack/react-query";
import type { MaintenanceRequest } from "@homes-map/shared";

async function fetchMaintenance(): Promise<{ data: MaintenanceRequest[] }> {
  const res = await fetch("/api/maintenance");
  if (!res.ok) throw new Error("Failed");
  return res.json();
}

const priorityColor: Record<string, string> = {
  low: "bg-gray-100 text-gray-600",
  medium: "bg-blue-100 text-blue-700",
  high: "bg-orange-100 text-orange-700",
  urgent: "bg-red-100 text-red-700",
};

export function MaintenancePage() {
  const { data, isLoading } = useQuery({ queryKey: ["maintenance"], queryFn: fetchMaintenance });

  if (isLoading) return <p className="text-gray-500">Loading…</p>;

  return (
    <div>
      <h1 className="text-2xl font-semibold mb-4">Maintenance</h1>
      <div className="space-y-3">
        {data?.data.map((m) => (
          <div key={m.id} className="bg-white border border-gray-200 rounded-xl p-4">
            <div className="flex items-start justify-between">
              <p className="font-medium">{m.title}</p>
              <span className={`text-xs font-semibold px-2 py-0.5 rounded ${priorityColor[m.priority] ?? ""}`}>
                {m.priority}
              </span>
            </div>
            <p className="text-sm text-gray-500 mt-1">{m.description}</p>
            <p className="text-xs text-gray-400 mt-1">Status: {m.status}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
