/**
 * Local mirror of the standard SAP EWM API "api_whse_physinvtryitem_2"
 * (Warehouse Physical Inventory Item, communication scenario SAP_COM_0378).
 *
 * This is a hand-written best-effort model of the entities and fields
 * documented for that API. It lets the project build and run before you
 * have sandbox credentials. Once you have a working "EWM_API_SANDBOX"
 * destination (see /README.md), replace this file with the real one by
 * running, from the project root in Business Application Studio:
 *
 *   cds import API_WHSE_PHYSINVENTORY --as cds
 *
 * That pulls the live $metadata from the destination and regenerates this
 * file (and srv/external/API_WHSE_PHYSINVENTORY.csn) to exactly match the
 * real service.
 */
namespace API_WHSE_PHYSINVENTORY;

@cds.external entity WhsePhysInvtryDoc {
  key Warehouse                    : String(4);
  key PhysicalInventoryDocument    : String(10);
      PhysInventoryDocIsCounted    : Boolean;
      PhysInventoryCountDate       : Date;
      PhysInventoryDocCreationDate : Date;
      PhysInventoryDocCreatedByUser: String(12);
      to_Item                      : Association to many WhsePhysInvtryItem
                                        on  to_Item.Warehouse = Warehouse
                                        and to_Item.PhysicalInventoryDocument = PhysicalInventoryDocument;
}

@cds.external entity WhsePhysInvtryItem {
  key Warehouse                   : String(4);
  key PhysicalInventoryDocument   : String(10);
  key PhysicalInventoryItem       : String(4);
      StorageBin                  : String(18);
      Product                     : String(40);
      StockOwner                  : String(10);
      StockType                   : String(2);
      BaseUnit                    : String(3);
      BookQuantity                 : Decimal(13,3);
      CountedQuantity              : Decimal(13,3);
      PhysInventoryItemIsCounted   : Boolean;
      to_Document                  : Association to one WhsePhysInvtryDoc
                                        on  to_Document.Warehouse = Warehouse
                                        and to_Document.PhysicalInventoryDocument = PhysicalInventoryDocument;
}
