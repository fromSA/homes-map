import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import type { Property } from "@homes-map/shared";

async function fetchProperties(): Promise<{ data: Property[] }> {
  const res = await fetch("/api/properties");
  if (!res.ok) throw new Error("Failed to fetch properties");
  return res.json();
}

export function PropertiesPage() {
  const { data, isLoading, error } = useQuery({ queryKey: ["properties"], queryFn: fetchProperties });

  if (isLoading) return <p className="text-gray-500">Loading properties…</p>;
  if (error) return <p className="text-red-500">Error loading properties.</p>;

  return (
    <div>
      <h1 className="text-2xl font-semibold mb-4">Properties</h1>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {data?.data.map((p) => (
          <Link
            key={p.id}
            to={`/properties/${p.id}`}
            className="block bg-white rounded-xl border border-gray-200 p-4 hover:shadow-md transition-shadow"
          >
            <p className="font-medium text-gray-900">{p.name}</p>
            <p className="text-sm text-gray-500">{p.address.city} · {p.type} · {p.totalAreaM2} m²</p>
            {p.energyRating && (
              <span className="mt-2 inline-block text-xs font-semibold px-2 py-0.5 rounded bg-green-100 text-green-700">
                Energy {p.energyRating}
              </span>
            )}
          </Link>
        ))}
      </div>
    </div>
  );
}
