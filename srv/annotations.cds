using PhysicalInventoryService as service from './service';

annotate service.PhysInvtryDocuments with @(
  UI.HeaderInfo: {
    TypeName      : 'Physical Inventory Document',
    TypeNamePlural: 'Physical Inventory Documents',
    Title         : { Value: PhysicalInventoryDocument },
    Description   : { Value: Warehouse }
  },
  UI.SelectionFields: [ Warehouse, PhysInventoryDocIsCounted ],
  UI.LineItem: [
    { Value: Warehouse,                     Label: 'Warehouse' },
    { Value: PhysicalInventoryDocument,     Label: 'Document' },
    { Value: PhysInventoryCountDate,        Label: 'Count Date' },
    { Value: PhysInventoryDocIsCounted,     Label: 'Counted' }
  ],
  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      Label : 'Items',
      Target: 'Items/@UI.LineItem'
    }
  ]
);

annotate service.PhysInvtryItems with @(
  UI.HeaderInfo: {
    TypeName      : 'Physical Inventory Item',
    TypeNamePlural: 'Physical Inventory Items',
    Title         : { Value: Product }
  },
  UI.LineItem: [
    { Value: PhysicalInventoryItem,      Label: 'Item' },
    { Value: StorageBin,                 Label: 'Storage Bin' },
    { Value: Product,                    Label: 'Product' },
    { Value: StockType,                  Label: 'Stock Type' },
    { Value: BookQuantity,               Label: 'Book Qty' },
    { Value: CountedQuantity,            Label: 'Counted Qty' },
    { Value: PhysInventoryItemIsCounted, Label: 'Counted' }
  ]
);
