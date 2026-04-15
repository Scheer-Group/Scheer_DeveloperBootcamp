using {sap.capire.bookshop as my} from '../db/schema';

using {businessPartner as external} from './external/businessPartner';

service AdminService @(odata: '/admin') {
  entity Authors         as projection on my.Authors;

  @odata.draft.enabled
  entity Books           as projection on my.Books;

  entity Genres          as projection on my.Genres;

  @odata.draft.enabled
  entity Orders          as
    projection on my.Orders {
      *,
      status    @readonly,
      netAmount @readonly,
      customer : redirected to BusinessPartner
    } actions {
      action process();
    };

  entity OrderItems      as
    projection on my.OrderItems {
      *,
      quantity,
      @title: '{i18n>OrderItem.netAmount}'
      quantity * book.price as netAmount : Decimal(15, 2) default 0.00
    };

  entity OrderStatuses   as projection on my.OrderStatuses;

  entity BusinessPartner as
    projection on external.A_BusinessPartner {
      key BusinessPartner,
          BusinessPartnerFullName
    };
}

annotate AdminService.OrderItems with {
  @assert.range        : [
    1,
    10
  ]
  @assert.range.message: '{i18n>quantityConstraint}'
  quantity;
};

annotate AdminService.Orders actions {
  @Core.OperationAvailable: {$edmJson: {$And: [
    {$Eq: [{$Path: 'IsActiveEntity'}, true]},
    {$Eq: [{$Path: 'status_code'}, 'NEW']}
  ]}}
  process;
};

// Additionally serve via HCQL and REST
annotate AdminService with  @hcql  @rest;
