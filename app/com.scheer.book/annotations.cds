using AdminService as service from '../../srv/admin-service';

annotate service.Books with @(
    UI.HeaderInfo : {
        TypeName       : '{i18n>Book.typeName}',
        TypeNamePlural : '{i18n>Book.typeNamePlural}',
        Title          : { Value : title },
        Description    : { Value : descr },
    },
    UI.SelectionFields : [
        title,
        author_ID,
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : title },
        { $Type : 'UI.DataField', Value : author_ID },
        { $Type : 'UI.DataField', Value : stock },
        { $Type : 'UI.DataField', Value : price },
    ],
    UI.FieldGroup #General : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            { $Type : 'UI.DataField', Value : title },
            { $Type : 'UI.DataField', Value : author_ID },
            { $Type : 'UI.DataField', Value : genre_ID },
        ],
    },
    UI.FieldGroup #Details : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            { $Type : 'UI.DataField', Value : descr },
            { $Type : 'UI.DataField', Value : stock },
            { $Type : 'UI.DataField', Value : price },
            { $Type : 'UI.DataField', Value : currency_code },
        ],
    },
    UI.Facets : [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GeneralFacet',
            Label  : '{i18n>Facet.General}',
            Target : '@UI.FieldGroup#General',
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'DetailsFacet',
            Label  : '{i18n>Facet.Details}',
            Target : '@UI.FieldGroup#Details',
        },
    ],
);

annotate service.Books with {
    author @Common: {
        Text           : author.name,
        TextArrangement: #TextFirst,
        ValueList      : {
            $Type          : 'Common.ValueListType',
            Label          : '{i18n>Author.typeName}',
            CollectionPath : 'Authors',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : author_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'dateOfBirth',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'dateOfDeath',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'placeOfBirth',
                },
            ],
        },
    };
    genre @Common: {
        Text           : genre.name,
        TextArrangement: #TextFirst,
        ValueList      : {
            $Type          : 'Common.ValueListType',
            Label          : '{i18n>Genre.typeName}',
            CollectionPath : 'Genres',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : genre_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
            ],
        },
    };
    currency @Common: {
        Text           : currency.name,
        TextArrangement: #TextFirst,
        ValueList      : {
            $Type          : 'Common.ValueListType',
            Label          : '{i18n>Currency.typeName}',
            CollectionPath : 'Currencies',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : currency_code,
                    ValueListProperty : 'code',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'symbol',
                },
            ],
        },
    };
};
