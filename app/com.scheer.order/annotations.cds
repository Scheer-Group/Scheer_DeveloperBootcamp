using AdminService as service from '../../srv/admin-service';

annotate service.Orders with @(
  UI.HeaderInfo         : {
    TypeName      : '{i18n>Order.typeName}',
    TypeNamePlural: '{i18n>Order.typeNamePlural}',
    Title         : {Value: customer_BusinessPartner},
    Description   : {Value: orderDate},
  },
  UI.SelectionFields    : [
    customer_BusinessPartner,
    status_code,
    orderDate,
  ],
  UI.LineItem           : [
    {
      $Type: 'UI.DataField',
      Value: orderDate
    },
    {
      $Type: 'UI.DataField',
      Value: customer_BusinessPartner
    },
    {
      $Type: 'UI.DataField',
      Value: status_code
    },
    {
      $Type: 'UI.DataField',
      Value: netAmount
    },
    {
      $Type: 'UI.DataField',
      Value: currency_code
    },
  ],
  UI.FieldGroup #General: {
    $Type: 'UI.FieldGroupType',
    Data : [
      {
        $Type: 'UI.DataField',
        Value: orderDate
      },
      {
        $Type: 'UI.DataField',
        Value: customer_BusinessPartner
      },
      {
        $Type: 'UI.DataField',
        Value: currency_code
      },
    ],
  },
  UI.FieldGroup #Status : {
    $Type: 'UI.FieldGroupType',
    Data : [
      {
        $Type: 'UI.DataField',
        Value: status_code
      },
      {
        $Type: 'UI.DataField',
        Value: netAmount
      },
    ],
  },
  UI.Identification     : [{
    $Type : 'UI.DataFieldForAction',
    Action: 'AdminService.process',
    Label : 'Process Order',
  }],
  UI.Facets             : [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'GeneralFacet',
      Label : '{i18n>Facet.General}',
      Target: '@UI.FieldGroup#General',
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'StatusFacet',
      Label : '{i18n>Facet.Status}',
      Target: '@UI.FieldGroup#Status',
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'ItemsFacet',
      Label : '{i18n>OrderItem.typeNamePlural}',
      Target: 'items/@UI.LineItem',
    },
  ],
);

annotate service.Orders with {
  @Measures.ISOCurrency: currency_code
  netAmount;
  status   @Common: {
    Text                    : status.name,
    TextArrangement         : #TextOnly,
    ValueListWithFixedValues: true,
    ValueList               : {
      $Type         : 'Common.ValueListType',
      Label         : '{i18n>Order.status}',
      CollectionPath: 'OrderStatuses',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: status_code,
          ValueListProperty: 'code',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'name',
        },
      ],
    },
  };
  customer @Common: {
    Text           : customer.BusinessPartnerFullName,
    TextArrangement: #TextFirst,
    ValueList      : {
      $Type         : 'Common.ValueListType',
      Label         : '{i18n>Order.status}',
      CollectionPath: 'BusinessPartner',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: customer_BusinessPartner,
          ValueListProperty: 'BusinessPartner',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'BusinessPartnerFullName',
        },
      ],
    },
  };
  currency @Common: {
    Text                    : currency.name,
    TextArrangement         : #TextFirst,
    ValueListWithFixedValues: true,
    ValueList               : {
      $Type         : 'Common.ValueListType',
      Label         : '{i18n>Order.currency}',
      CollectionPath: 'Currencies',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: currency_code,
          ValueListProperty: 'code',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'name',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'symbol',
        },
      ],
    },
  };
};

annotate service.OrderItems with @(
  Common.SideEffects #netAmountUpdate: {
    SourceProperties: [
      'book_ID',
      'quantity'
    ],
    TargetProperties: ['netAmount'],
    TargetEntities  : [order],
  },
  UI.LineItem                        : [
    {
      $Type: 'UI.DataField',
      Value: book_ID
    },
    {
      $Type: 'UI.DataField',
      Value: quantity
    },
    {
      $Type: 'UI.DataField',
      Value: netAmount
    },
  ],
);


annotate service.OrderItems with {
  @(Common: {
    Text                    : book.title,
    TextArrangement         : #TextOnly,
    ValueListWithFixedValues: true,
    ValueList               : {
      $Type         : 'Common.ValueListType',
      Label         : '{i18n>OrderItem.book}',
      CollectionPath: 'Books',
      Parameters    : [
        {
          $Type            : 'Common.ValueListParameterInOut',
          LocalDataProperty: book_ID,
          ValueListProperty: 'ID',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'title',
        },
        {
          $Type            : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'author_ID',
        },
      ],
    },
  })
  book;
  @Measures.ISOCurrency: order.currency_code
  netAmount;
};

annotate service.BusinessPartner with {
  @Common.Text           : BusinessPartnerFullName
  @Common.TextArrangement: #TextFirst
  BusinessPartner;
};
