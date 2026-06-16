const propertiesEl = document.getElementById("properties");
const flowRatesEl = document.getElementById("flow-rates");
const refreshBtn = document.getElementById("refresh-btn");

async function fetchJson(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }
  return response.json();
}

function formatPercent(value) {
  return `${value.toFixed(0)}%`;
}

function formatHours(value) {
  return `${value.toFixed(1)} h`;
}

function formatEfficiency(value) {
  return value == null ? "-" : `${value.toFixed(2)} kWh/m2`;
}

function renderFlowRates(property, rates) {
  flowRatesEl.classList.remove("empty");

  const paymentClass = rates.rentPaymentOnTimePct < 70 ? "metric warn" : "metric";
  const maintenanceClass = rates.avgMaintenanceResolutionHours > 48 ? "metric warn" : "metric";

  flowRatesEl.innerHTML = `
    <h3>${property.name}</h3>
    <p class="meta">${property.address.street}, ${property.address.city}</p>
    <div class="metrics">
      <div class="${paymentClass}">
        <div class="label">On-time payments</div>
        <div class="value">${formatPercent(rates.rentPaymentOnTimePct)}</div>
      </div>
      <div class="${maintenanceClass}">
        <div class="label">Avg maintenance resolution</div>
        <div class="value">${formatHours(rates.avgMaintenanceResolutionHours)}</div>
      </div>
      <div class="metric">
        <div class="label">Energy efficiency</div>
        <div class="value">${formatEfficiency(rates.energyEfficiencyKWhPerM2)}</div>
      </div>
    </div>
  `;
}

function renderProperties(properties) {
  propertiesEl.innerHTML = "";

  for (const property of properties) {
    const card = document.createElement("article");
    card.className = "card";
    card.innerHTML = `
      <h3>${property.name}</h3>
      <p class="meta">${property.address.city} · ${property.propertyType.toLowerCase()} · ${property.totalAreaM2} m2</p>
      <button type="button">View Flow Rates</button>
    `;

    const button = card.querySelector("button");
    button.addEventListener("click", async () => {
      flowRatesEl.innerHTML = "Loading flow rates...";
      flowRatesEl.classList.add("empty");
      try {
        const rates = await fetchJson(`/api/properties/${property.propertyKey}/flow-rates`);
        renderFlowRates(property, rates);
      } catch (error) {
        flowRatesEl.classList.add("empty");
        flowRatesEl.textContent = `Could not load flow rates: ${error.message}`;
      }
    });

    propertiesEl.appendChild(card);
  }
}

async function loadProperties() {
  propertiesEl.textContent = "Loading properties...";
  try {
    const properties = await fetchJson("/api/properties");
    renderProperties(properties);
  } catch (error) {
    propertiesEl.textContent = `Could not load properties: ${error.message}`;
  }
}

refreshBtn.addEventListener("click", loadProperties);
loadProperties();
