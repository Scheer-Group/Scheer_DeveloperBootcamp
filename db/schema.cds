namespace sap.capire.bookshop;

using {
  Currency,
  cuid,
  managed,
  sap
} from '@sap/cds/common';

using {businessPartner as external} from '../srv/external/businessPartner';

entity Books : cuid, managed {
  author   : Association to Authors  @mandatory  @title: '{i18n>Book.author}';
  title    : localized String        @mandatory  @title: '{i18n>Book.title}';
  descr    : localized String(2000)  @title: '{i18n>Book.descr}';
  genre    : Association to Genres   @title: '{i18n>Book.genre}';
  stock    : Integer                 @title: '{i18n>Book.stock}';
  price    : Decimal(9, 2)           @title: '{i18n>Book.price}';
  currency : Currency                @title: '{i18n>Book.currency}';
}

entity Authors : managed {
  key ID           : Integer @title: '{i18n>Author.ID}';
      name         : String  @mandatory  @title: '{i18n>Author.name}';
      dateOfBirth  : Date    @title: '{i18n>Author.dateOfBirth}';
      dateOfDeath  : Date    @title: '{i18n>Author.dateOfDeath}';
      placeOfBirth : String  @title: '{i18n>Author.placeOfBirth}';
      placeOfDeath : String  @title: '{i18n>Author.placeOfDeath}';
      books        : Association to many Books
                       on books.author = $self;
}

/** Hierarchically organized Code List for Genres */
entity Genres : cuid, sap.common.CodeList {
  parent   : Association to Genres;
  children : Composition of many Genres
               on children.parent = $self;
}

entity Orders : cuid, managed {
  orderDate : Date                                          @mandatory  @title: '{i18n>Order.orderDate}';
  customer  : Association to one external.A_BusinessPartner @title: '{i18n>Order.customer}' @mandatory;
  status    : Association to OrderStatuses default 'NEW'    @title: '{i18n>Order.status}';
  currency  : Currency                                      @title: '{i18n>Order.currency}';
  netAmount : Decimal(9, 2) default 0                       @title: '{i18n>Order.netAmount}';
  items     : Composition of many OrderItems
                on items.order = $self;
}

entity OrderItems : cuid {
  order    : Association to Orders @mandatory;
  book     : Association to Books  @mandatory  @title: '{i18n>OrderItem.book}';
  quantity : Integer               @mandatory  @title: '{i18n>OrderItem.quantity}';
}

entity OrderStatuses : sap.common.CodeList {
  key code : String(20);
}

annotate Books with @fiori.draft.enabled;
