# SAP EWM Physical Inventory Demo

A demo app built with **SAP Fiori Elements** (List Report + Object Page) on top of
**SAP Cloud Application Programming Model (CAP)**, consuming the standard SAP
EWM API **`api_whse_physinvtryitem_2`** ("Warehouse Physical Inventory Item",
part of communication scenario `SAP_COM_0378`).

- List Report shows Physical Inventory **Documents** for a warehouse.
- Drilling into a document opens an Object Page with its **Items**
  (storage bin, product, book quantity vs. counted quantity, counted flag).

## Project layout

| Folder / file | Purpose |
|---|---|
| `srv/external/API_WHSE_PHYSINVENTORY.cds` | Local mirror of the real SAP API's entities. **Placeholder** — regenerate from the real service once you have sandbox access (see below). |
| `srv/service.cds` | `PhysicalInventoryService` — our CAP service, a thin read-only projection over the external API. |
| `srv/annotations.cds` | Fiori UI annotations (`@UI.LineItem`, `@UI.HeaderInfo`, `@UI.Facets`) driving the Fiori Elements pages. |
| `app/physicalinventory/` | The Fiori Elements app (`sap.fe.templates.ListReport` / `ObjectPage`). |

This was verified locally: `cds compile` produces valid OData V4 EDMX with the
UI annotations, and `cds watch` serves the service correctly. It has **not**
been tested end-to-end against the real EWM API, since that requires your own
SAP API Business Hub key (see below).

## Prerequisites

1. An SAP BTP account (a free trial account is enough) with a
   **Business Application Studio** *Full-Stack Cloud Application* dev space.
2. A key for the **SAP API Business Hub** sandbox:
   go to [api.sap.com](https://api.sap.com), sign in, open the
   [Warehouse Physical Inventory Item API](https://api.sap.com/api/api_whse_physinvtryitem_2),
   and copy your API key from the "Show API Key" button.

## Setup in Business Application Studio

1. Clone this repo/branch into your dev space and run `npm install`.
2. Get the exact live entity model instead of the hand-written placeholder:
   ```bash
   cds import API_WHSE_PHYSINVENTORY --as cds
   ```
   Configuring credentials for this command is covered by option A below —
   do this step after you've set up a working connection, then re-run it.

### Option A — quick local run (start here)

BAS dev spaces have outbound internet access, so you can call the sandbox
directly without setting up a BTP destination first. Create a
**git-ignored** `.cdsrc-private.json` in the project root:

```json
{
  "requires": {
    "API_WHSE_PHYSINVENTORY": {
      "credentials": {
        "url": "https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata4/sap/api_whse_physinvtryitem_2/srvd_a2x/sap/whsephysicalinventorydoc/0001",
        "headers": { "APIKey": "<your API Business Hub key>" }
      }
    }
  }
}
```

This overrides the `destination`-based config in `package.json` for local
runs only. Then:

```bash
cds watch
```

Open the app at the printed URL, path `/physicalinventory/webapp/index.html`
(or use the "Open Preview" link CAP prints for `PhysInvtryDocuments`).

### Option B — BTP destination (for a "real" setup / deployment)

1. In your BTP subaccount cockpit, create a destination named
   **`EWM_API_SANDBOX`**:
   - URL: `https://sandbox.api.sap.com`
   - Authentication: `NoAuthentication`
   - Additional property: `URL.headers.APIKey` = `<your API Business Hub key>`
2. `package.json` already points `API_WHSE_PHYSINVENTORY` at this destination
   name — no code change needed.
3. For local/hybrid testing against it, bind the destination service to your
   dev space and run `cds bind` (see the
   [CAP docs on hybrid testing](https://cap.cloud.sap/docs/advanced/hybrid-testing)),
   then `cds watch --profile hybrid`.
4. This is also the setup you'd keep when deploying the app (`cds add mta`
   + `cf deploy`), since it doesn't hard-code your API key anywhere.

## Running

```bash
cds watch
```

- OData service: `http://localhost:4004/physical-inventory/`
- Fiori app: `http://localhost:4004/physicalinventory/webapp/index.html`
- CAP's built-in Fiori preview (no app build needed):
  the index page CAP serves at `http://localhost:4004/` links to it directly.

## Learn more

- API details: [api.sap.com/api/api_whse_physinvtryitem_2](https://api.sap.com/api/api_whse_physinvtryitem_2)
- CAP: <https://cap.cloud.sap>
- Fiori Elements: <https://ui5.sap.com/#/topic/797c3239b1a5435693d0f75e34d99191>
