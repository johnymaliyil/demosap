using { API_WHSE_PHYSINVENTORY as external } from './external/API_WHSE_PHYSINVENTORY';

/**
 * Demo service exposing SAP EWM Physical Inventory documents and items,
 * proxied live from the standard SAP API "api_whse_physinvtryitem_2".
 */
service PhysicalInventoryService @(path: '/physical-inventory') {

  @readonly
  entity PhysInvtryDocuments as projection on external.WhsePhysInvtryDoc {
    *,
    to_Item as Items : redirected to PhysInvtryItems
  };

  @readonly
  entity PhysInvtryItems as projection on external.WhsePhysInvtryItem;
}
