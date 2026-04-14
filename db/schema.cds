using { Currency, cuid, managed, sap } from '@sap/cds/common';
namespace sap.capire.bookshop;

entity Books : cuid, managed {
  author   : Association to Authors @mandatory  @title: '{i18n>Book.author}';
  title    : localized String @mandatory        @title: '{i18n>Book.title}';
  descr    : localized String(2000)             @title: '{i18n>Book.descr}';
  genre    : Association to Genres              @title: '{i18n>Book.genre}';
  stock    : Integer                            @title: '{i18n>Book.stock}';
  price    : Price                              @title: '{i18n>Book.price}';
  currency : Currency                           @title: '{i18n>Book.currency}';
}

entity Authors : managed {
  key ID       : Integer  @title: '{i18n>Author.ID}';
  name         : String @mandatory @title: '{i18n>Author.name}';
  dateOfBirth  : Date   @title: '{i18n>Author.dateOfBirth}';
  dateOfDeath  : Date   @title: '{i18n>Author.dateOfDeath}';
  placeOfBirth : String @title: '{i18n>Author.placeOfBirth}';
  placeOfDeath : String @title: '{i18n>Author.placeOfDeath}';
  books        : Association to many Books on books.author = $self;
}

/** Hierarchically organized Code List for Genres */
entity Genres : cuid, sap.common.CodeList {
  parent   : Association to Genres;
  children : Composition of many Genres on children.parent = $self;
}

type Price : Decimal(9,2);


// --------------------------------------------------------------------------------
// Temporary workaround for this situation:
// - Fiori apps in bookstore annotate Books with @fiori.draft.enabled.
// - Because of that .csv data has to eagerly fill in ID_texts column.
annotate Books with @fiori.draft.enabled;
