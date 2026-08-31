# SAP EWM Physical Inventory Demo

A **SAP Fiori Elements** app (List Report + Object Page) deployed directly
into the ABAP UI5 repository of an S/4HANA system with embedded EWM,
consuming the standard SAP EWM API **`api_whse_physinvtryitem_2`**
("Warehouse Physical Inventory Item", communication scenario `SAP_COM_0378`)
**locally, same-origin** — no middle tier, no CORS.

- List Report shows Physical Inventory **Items** for a warehouse (one row
  per document/item — this API has no separate document-header entity).
- Drilling into a row opens an Object Page with its **Count Items**
  (storage bin, product, batch, stock type/owner, quantity entered).

> This project was previously scaffolded as a CAP (Node.js) app proxying the
> public API Business Hub sandbox, then reworked to deploy straight into the
> ABAP system once real system access was available (no middle tier needed
> when frontend and backend run on the same box).

## Project layout

| Path | Purpose |
|---|---|
| `webapp/manifest.json` | App descriptor. `mainService` points at the real local OData path; `annotation` data source references the local UI annotation file. |
| `webapp/annotations/annotation.xml` | Fiori UI annotations (`UI.LineItem`, `UI.HeaderInfo`, `UI.Facets`) — **verified against the real `$metadata`** from `dw4.sap.solar.eu`. |
| `webapp/` (rest) | Standard Fiori Elements app files (`Component.js`, `index.html` for local preview, `i18n/`). |
| `ui5.yaml` | Local dev server config — `fiori-tools-proxy` routes backend calls through the `dw4-bas` BTP destination (Cloud Connector). |
| `ui5-deploy.yaml` | Deployment config for `deploy-to-abap` — deploys directly to `https://dw4.sap.solar.eu:44300`. |

## Real entity model (confirmed)

Namespace: `com.sap.gateway.srvd_a2x.api_whse_physinvtryitem_2.v0001`

- **`WhsePhysicalInventoryItem`** (entity type `WhsePhysicalInventoryItemType`)
  — the List Report's rows. Key: `EWMWarehouse` + `PhysicalInventoryDocNumber`
  + `PhysicalInventoryDocYear` + `PhysicalInventoryItemNumber`.
- **`WhsePhysicalInventoryCountItem`** (entity type
  `WhsePhysicalInventoryCountItemType`) — composition child via navigation
  property `_WhsePhysicalInventoryCntItem`, shown as a table on the Object
  Page. Storage bin/type, product, batch, stock type/owner, and
  `RequestedQuantity` (the entered count quantity — this API does **not**
  expose a book/expected quantity to compare against).
- A third entity, `WhsePhysicalInventorySrlNmbr` (serial numbers), exists as
  a child of the count item but isn't surfaced in this demo's UI.

## Setup in Business Application Studio (via Cloud Connector)

### 1. Expose the system to BTP

Cloud Connector maps your S/4HANA host as an on-premise resource to your BTP
subaccount; a destination named **`dw4-bas`** (referenced in `ui5.yaml`) then
routes local dev traffic through it. `ui5-deploy.yaml` instead deploys via a
**direct URL** (`https://dw4.sap.solar.eu:44300`) — confirm your BAS dev
space can actually reach that host directly for deploy to work; if not,
switch `ui5-deploy.yaml` to a `destination:` the same way `ui5.yaml` does.

### 2. Activate/publish the OData service

Confirmed working path for this system: **SAP Gateway Service
Administration** (`/IWBEP/SUPPORT` or similar) → **Publish Service Groups**
→ search `API_WHSE_PHYSINVTRYITEM_2` → assign to system alias → publish.
(General alternative: activate communication scenario `SAP_COM_0378`, or
publish the Service Binding directly from Eclipse ADT.)

### 3. Run and preview

```bash
npm install
npm start
```

## Deploying to your ABAP system

1. Edit `ui5-deploy.yaml`:
   - `app.name` — a valid BSP application name in your namespace (Z/Y
     prefix, max 15 chars). Currently `ZDEMO_PHYSINV`.
   - `app.package` — an existing, transportable ABAP package (not `$TMP`).
     Currently `ZDEMO_EWM`.
   - `app.transport` — **get your own transport request** for this app
     (SE09/SE10, or let `npm run deploy` prompt you) — don't reuse a
     transport that belongs to a different app/change.
2. Deploy:
   ```bash
   npm run build
   npm run deploy
   ```
3. **Register it in the Fiori Launchpad**: create (or reuse) a catalog and
   group via the Launchpad Content Manager / `/UI2/FLPCM_CUST`, add a tile
   for the deployed app (semantic object + action pointing at your BSP app),
   and assign the catalog to the relevant PFCG role(s).
4. To remove it later: `npm run undeploy`.

## Learn more

- API details: [api.sap.com/api/api_whse_physinvtryitem_2](https://api.sap.com/api/api_whse_physinvtryitem_2)
- SAP Fiori tools deploy-to-ABAP: search SAP Help Portal for "Deploying to an ABAP System"
- Fiori Elements: <https://ui5.sap.com/#/topic/797c3239b1a5435693d0f75e34d99191>
