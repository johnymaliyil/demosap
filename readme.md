# SAP EWM Physical Inventory Demo

A **SAP Fiori Elements** app (List Report + Object Page) deployed directly
into the ABAP UI5 repository of an S/4HANA system with embedded EWM,
consuming the standard SAP EWM API **`api_whse_physinvtryitem_2`**
("Warehouse Physical Inventory Item", communication scenario `SAP_COM_0378`)
**locally, same-origin** — no middle tier, no CORS, no BTP destination at
runtime.

- List Report shows Physical Inventory **Documents** for a warehouse.
- Drilling into a document opens an Object Page with its **Items**
  (storage bin, product, book quantity vs. counted quantity, counted flag).

> This project was previously scaffolded as a CAP (Node.js) app proxying the
> public API Business Hub sandbox. Since you have direct access to a real
> S/4HANA 2023 Private Cloud system with EWM and the Fiori front-end server
> on the same box, that middle tier has been removed — the app now talks to
> your system's own OData service directly, which is the standard pattern
> for this deployment topology.

## Project layout

| Path | Purpose |
|---|---|
| `webapp/manifest.json` | App descriptor. `mainService` points at the real local OData path; `annotation` data source references the local UI annotation file. |
| `webapp/annotations/annotation.xml` | Fiori UI annotations (`UI.LineItem`, `UI.HeaderInfo`, `UI.Facets`). **Placeholder** — see "Before you start" below. |
| `webapp/` (rest) | Standard Fiori Elements app files (`Component.js`, `index.html` for local preview, `i18n/`). |
| `ui5.yaml` | Local dev server config — `fiori-tools-proxy` routes backend calls to your system through a BTP destination (via Cloud Connector). |
| `ui5-deploy.yaml` | Deployment config for `deploy-to-abap` — pushes the built app into your ABAP system's UI5 repository. |

Verified locally: `npx ui5 build` succeeds and produces a valid app bundle;
`ui5-deploy.yaml`'s schema was validated with `fiori deploy --testMode`. It
has **not** been tested against your real system — I have no network path to
your on-prem landscape from here.

## Before you start: fix the placeholders

Two things in this scaffold are best-effort guesses, not read from your
system's real metadata:

1. **`webapp/annotations/annotation.xml`** — the entity type names
   (`WhsePhysInvtryDoc` / `WhsePhysInvtryItem`) and their fields are inferred
   from the API's documentation, not fetched live. A mismatched `Target`
   is silently ignored by UI5 (no error, columns just don't appear).
2. **`webapp/manifest.json`** — entity *set* names in `routing` (also
   `WhsePhysInvtryDoc`) are the same kind of guess.

**Most reliable fix:** once you're in Business Application Studio with the
destination below working, use **SAP Fiori tools → Open Application
Generator**, point it at your system's `api_whse_physinvtryitem_2` service,
and let it read the real `$metadata` to (re)generate `manifest.json` and the
annotations. You can then port the column/facet choices from this scaffold's
`annotation.xml` into what it generates. Alternatively, fetch
`$metadata` yourself (browser or `curl` through the working proxy) and
correct the names by hand.

## Setup in Business Application Studio (via Cloud Connector)

### 1. Expose the system to BTP

1. In **SAP Cloud Connector**, add your S/4HANA system's host/port as an
   accessible on-premise resource (a "virtual host" mapped to the internal
   host), and assign the resource to the BTP subaccount your BAS dev space
   runs in.
2. In that BTP subaccount's cockpit, create a **destination** named
   **`EWM_ON_PREM`** (this exact name is what `ui5.yaml` / `ui5-deploy.yaml`
   already reference):
   - URL: the virtual host from Cloud Connector
   - Proxy Type: `OnPremise`
   - Authentication: whatever your system requires for the Gateway user
     (Basic, or Principal Propagation if you have that set up)
   - Additional property: `sap-client` = your client (also set directly as
     `client:` in the YAML files, so this is mostly belt-and-braces)

### 2. Activate the OData service on the ABAP side

The API is released by SAP but not necessarily active in `/IWFND/MAINT_SERVICE`
by default. With a Basis/functional consultant (or yourself, if authorized):

1. Activate communication scenario **`SAP_COM_0378`** (or activate the
   `api_whse_physinvtryitem_2` service directly via `/IWFND/MAINT_SERVICE` /
   `/n/IWFND/MAINT_SERVICE`, system alias pointing at the EWM/S4 system
   itself since it's embedded).
2. Confirm the ICF node under `/sap/opu/odata4/sap/api_whse_physinvtryitem_2`
   is active in `SICF`.
3. Make sure your Gateway/Fiori user has authorization for physical
   inventory display (the relevant `S_SCWM_*` / API-specific auth objects).

### 3. Run and preview

```bash
npm install
npm start
```

This serves the app locally (through the `fiori-tools-proxy` → `EWM_ON_PREM`
destination → Cloud Connector → your system) with live reload, and opens a
Fiori Launchpad sandbox preview. This is also when you should fetch real
`$metadata` and fix the placeholders above.

## Deploying to your ABAP system

1. Edit `ui5-deploy.yaml`:
   - `app.name` — a valid BSP application name in your namespace (Z/Y
     prefix, max 15 chars).
   - `app.package` — an existing, transportable ABAP package (not `$TMP`).
   - `app.transport` — a transport request, or leave `""` to be prompted.
2. Deploy:
   ```bash
   npm run build
   npm run deploy
   ```
   This uploads the built app into the ABAP system's UI5 repository
   (`/UI5/UI5_REPOSITORY_LOAD` under the hood) via the same `EWM_ON_PREM`
   destination.
3. **Register it in the Fiori Launchpad**: create (or reuse) a catalog and
   group via the Launchpad Content Manager / `/UI2/FLPCM_CUST`, add a tile
   for the deployed app (semantic object + action pointing at your BSP app),
   and assign the catalog to the relevant PFCG role(s).
4. To remove it later: `npm run undeploy`.

## Learn more

- API details: [api.sap.com/api/api_whse_physinvtryitem_2](https://api.sap.com/api/api_whse_physinvtryitem_2)
- SAP Fiori tools deploy-to-ABAP: search SAP Help Portal for "Deploying to an ABAP System"
- Fiori Elements: <https://ui5.sap.com/#/topic/797c3239b1a5435693d0f75e34d99191>
