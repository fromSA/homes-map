import { Routes, Route, Link } from "react-router-dom";
import { PropertiesPage } from "./pages/PropertiesPage.js";
import { PropertyDetailPage } from "./pages/PropertyDetailPage.js";
import { ContractsPage } from "./pages/ContractsPage.js";
import { MaintenancePage } from "./pages/MaintenancePage.js";

export default function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white border-b border-gray-200 px-6 py-3 flex items-center gap-6">
        <span className="font-bold text-lg text-indigo-600">homes-map</span>
        <Link to="/" className="text-sm text-gray-600 hover:text-indigo-600">Properties</Link>
        <Link to="/contracts" className="text-sm text-gray-600 hover:text-indigo-600">Contracts</Link>
        <Link to="/maintenance" className="text-sm text-gray-600 hover:text-indigo-600">Maintenance</Link>
      </nav>
      <main className="p-6">
        <Routes>
          <Route path="/" element={<PropertiesPage />} />
          <Route path="/properties/:id" element={<PropertyDetailPage />} />
          <Route path="/contracts" element={<ContractsPage />} />
          <Route path="/maintenance" element={<MaintenancePage />} />
        </Routes>
      </main>
    </div>
  );
}
