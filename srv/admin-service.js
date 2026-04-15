'use strict';

const cds = require('@sap/cds');

module.exports = class AdminService extends cds.ApplicationService {
  async init() {
    const bupa = await cds.connect.to('businessPartner');
    const { BusinessPartner, Orders, OrderItems } = cds.entities(this.name);

    this.on('READ', BusinessPartner, (req) => {
      return bupa.run(req.query);
    });

    this.on('READ', [Orders, Orders.drafts], async (req, next) => {
      const columns = req.query.SELECT.columns;
      if (!columns) {
        return next();
      }

      const expandIndex = columns.findIndex(({ expand, ref }) => {
        return expand && ref[0] === 'customer';
      });

      if (expandIndex < 0) {
        return next();
      }

      const expandColumns = columns[expandIndex].expand;

      columns.splice(expandIndex, 1);

      if (columns.indexOf('*') < 0 && !columns.find((c) => c.ref?.[0] === 'customer_BusinessPartner')) {
        columns.push({ ref: ['customer_BusinessPartner'] });
      }

      if (expandColumns.indexOf('*') < 0 && !expandColumns.find((c) => c.ref?.includes('BusinessPartner'))) {
        expandColumns.push({ ref: ['BusinessPartner'] });
      }

      const orders = await next();
      const arr = Array.isArray(orders) ? orders : orders ? [orders] : [];

      if (!arr.length) {
        return orders;
      }

      const ids = [...new Set(arr.map((o) => o.customer_BusinessPartner).filter(Boolean))];

      if (!ids.length) {
        return orders;
      }

      const bps = await bupa.run(
        SELECT(expandColumns)
          .from('A_BusinessPartner')
          .where({ BusinessPartner: { in: ids } })
      );

      const bpMap = new Map(bps.map((bp) => [bp.BusinessPartner, bp]));

      for (const order of arr) {
        order.customer = bpMap.get(order.customer_BusinessPartner) ?? null;
      }

      return orders;
    });

    this.on('process', Orders, async (req) => {
      const [{ ID }] = req.params;
      await UPDATE.entity(Orders).set({ status_code: 'IN_PROGRESS' }).where({ ID });
    });

    this.after(['PATCH', 'DELETE'], OrderItems.drafts, async (_, req) => {
      const [{ ID }] = req.params;
      const sum = await SELECT.one
        .from(OrderItems.drafts)
        .where({ order_ID: ID })
        .columns('sum(netAmount) as sunAmount');
      const rounded = Number((sum.sunAmount ?? 0).toFixed(2));
      await UPDATE.entity(Orders.drafts).set({ netAmount: rounded }).where({ ID });
    });

    return super.init();
  }
};
