# CAP Fiori Elements Challenge

## Overview

You are working on a bookshop backend built with **SAP Cloud Application Programming Model (CAP)** and **Node.js**. The project already provides a basic `AdminService` exposing `Books`, `Authors`, and `Genres`. Books already have a `price` field. The S/4HANA Business Partner API is pre-configured as a remote service — the metadata is at `srv/external/businessPartner.csn` and the service is registered in `package.json`.

Work through the challenges in order. Each one builds on the previous.

---

## Challenge 1 — Expose the Business Partner

The Business Partner remote service is already connected. Your job is to project it through `AdminService` so it is accessible as an OData endpoint.

Expose at minimum the Business Partner ID and full name. Delegate reads to the remote system via a service handler.

**Verify:** Open the CAP index page (`cds watch`) and confirm you can browse Business Partner data.

> Reference: [Expose Remote Services with Associations](https://cap.cloud.sap/docs/guides/services/consuming-services#expose-remote-services-with-associations)

---

## Challenge 2 — Order Data Model

Create the data model for orders.

An **order** has an order date, a status (starting at `NEW`), a currency, and a net amount. An **order item** belongs to an order, references a book, and has a quantity. Think about what constraints are appropriate on quantity.

Add seed data for the order status code list. Include at least `NEW`, `IN_PROGRESS`, and `SHIPPED`.

Do not worry about the Business Partner or calculated amounts yet — keep the model simple for now.

**Verify:** Expose the entities in `AdminService` and confirm the tables are created on `cds watch`.

---

## Challenge 3 — Basic Fiori Elements App

Create a Fiori Elements V4 **List Report + Object Page** application for orders.

The list should show the key order fields. The object page should be split into two sections:
- A **General** section with the order date and currency
- A **Status & Amount** section with the status and net amount

Below those, show the order items in a table with book and quantity.

Keep it basic for now — no calculated amounts, no value helps beyond what Fiori generates automatically, no action buttons.

> Use the **SAP Fiori Tools** VS Code extension to generate the app: run `Fiori: Open Application Generator`, choose the `List Report Page` template, and point it at the local CAP project.

**Verify:** Run `cds watch`, open the app, create a draft order with a few items, and activate it.

---

## Challenge 4 — Reference Business Partner

Connect orders to the Business Partner. Each order should reference a customer.

Add the customer field to the data model and expose it correctly in the service. The customer association points to a remote OData service, which means CAP cannot resolve it automatically — you will need a service handler that fetches the matching Business Partners and stitches them onto the order results.

In the UI, the customer field should show the full name (not the raw ID) and offer a value help dropdown backed by the Business Partner collection.

**Verify:** Create an order, assign a customer, save it, and confirm the customer name appears in both the list and the object page.

---

## Challenge 5 — Calculated Values

Add financial calculations to the model.

Each order item should display a calculated amount (quantity × book price). The order itself should carry the sum of all item amounts as its net amount, kept in sync whenever items are added, changed, or removed.

In the UI, changing the book or quantity on an item should immediately refresh both the item amount and the order net amount — no page reload required.

**Verify:** Create an order with two items. Change the quantity of one. Confirm both the item amount and the order net amount update live in the UI.

> Tip: Use `@Common.SideEffects` on the `OrderItems` entity to declare which source properties trigger which targets to refresh. You can reference the parent entity as a target:
> ```cds
> annotate service.OrderItems with @(
>   Common.SideEffects #netAmountUpdate: {
>     SourceProperties: ['book_ID', 'quantity'],
>     TargetProperties: ['netAmount'],
>     TargetEntities  : [order],
>   }
> );
> ```

---

## Challenge 6 — Bound Actions & Order Protection

Add lifecycle actions to orders and enforce status rules.

**Actions:**

| Action | Transition | Available when |
|--------|-----------|----------------|
| Process Order | `NEW` → `IN_PROGRESS` | Active entity, status `NEW` |
| Ship Order | `IN_PROGRESS` → `SHIPPED` | Active entity, status `IN_PROGRESS` |

Both actions require no input and no business validation beyond the availability check. Surface them as buttons on the object page toolbar — each button should only be enabled under the conditions above.

**Protection:** Orders in status `SHIPPED` must not be edited or deleted. Enforce this in the service layer.

> Tip: Use `@Core.OperationAvailable` with an `$edmJson` expression to control button availability declaratively. You can combine multiple conditions with `$And`.

**Verify:** Process and ship an order. Confirm the buttons enable and disable as the status changes. Try editing a shipped order and confirm it is rejected.

---

## Acceptance Criteria

| # | Criterion |
|---|-----------|
| 1 | `cds watch` starts without errors |
| 2 | Business Partner data is browsable via the AdminService OData endpoint |
| 3 | Creating an order draft initialises status `NEW` and net amount `0` |
| 4 | Adding, changing, or removing an item keeps the order net amount in sync |
| 5 | Exceeding the maximum item quantity is rejected with a descriptive error |
| 6 | Customer field shows the full name; value help lists available Business Partners |
| 7 | Changing book or quantity on an item refreshes amounts live in the UI |
| 8 | `Process Order` moves status to `IN_PROGRESS` and is only enabled on new orders |
| 9 | `Ship Order` moves status to `SHIPPED` and is only enabled on in-progress orders |
| 10 | Editing or deleting a shipped order is rejected |
| 11 | All unit tests pass (`npm test`) |
