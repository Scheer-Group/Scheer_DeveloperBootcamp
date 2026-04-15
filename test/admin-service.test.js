'use strict';

const cds = require('@sap/cds');

const { POST, PATCH, DELETE, GET } = cds.test(__dirname + '/..');

const BOOK_ID = '65bc6dea-17e2-4b18-9871-ce7a2137aa73';
const BOOK_PRICE = 14;

describe('AdminService', () => {
    it('creating an order draft sets status to NEW and netAmount to 0', async () => {
        const res = await POST('admin/Orders', {
            orderDate: '2026-01-15',
        });

        expect(res.data.status_code).toBe('NEW');
        expect(Number(res.data.netAmount)).toBe(0);
    });

    it('adding an order item updates order netAmount', async () => {
        const orderRes = await POST('admin/Orders', {
            orderDate: '2026-01-15',
        });

        const orderId = orderRes.data.ID;

        const itemRes = await POST(`admin/Orders(ID=${orderId},IsActiveEntity=false)/items`, {
            book_ID: BOOK_ID,
            quantity: 3,
        });

        const itemId = itemRes.data.ID;

        await PATCH(`admin/OrderItems(ID=${itemId},IsActiveEntity=false)`, {
            book_ID: BOOK_ID,
            quantity: 3,
        });

        const orderRes2 = await GET(`admin/Orders(ID=${orderId},IsActiveEntity=false)`);

        expect(Number(orderRes2.data.netAmount)).toBe(3 * BOOK_PRICE);
    });

    it('changing item quantity recalculates order netAmount', async () => {
        const orderRes = await POST('admin/Orders', {
            orderDate: '2026-01-15',
        });

        const orderId = orderRes.data.ID;

        const itemRes = await POST(`admin/Orders(ID=${orderId},IsActiveEntity=false)/items`, {
            book_ID: BOOK_ID,
            quantity: 2,
        });

        const itemId = itemRes.data.ID;

        await PATCH(`admin/OrderItems(ID=${itemId},IsActiveEntity=false)`, {
            quantity: 5,
        });

        const orderRes2 = await GET(`admin/Orders(ID=${orderId},IsActiveEntity=false)`);

        expect(Number(orderRes2.data.netAmount)).toBe(5 * BOOK_PRICE);
    });

    it('deleting an order item decreases order netAmount', async () => {
        const orderRes = await POST('admin/Orders', {
            orderDate: '2026-01-15',
        });

        const orderId = orderRes.data.ID;

        const item1Res = await POST(`admin/Orders(ID=${orderId},IsActiveEntity=false)/items`, {
            book_ID: BOOK_ID,
            quantity: 3,
        });

        await POST(`admin/Orders(ID=${orderId},IsActiveEntity=false)/items`, {
            book_ID: BOOK_ID,
            quantity: 2,
        });

        await PATCH(`admin/OrderItems(ID=${item1Res.data.ID},IsActiveEntity=false)`, {
            book_ID: BOOK_ID,
            quantity: 3,
        });

        await DELETE(`admin/OrderItems(ID=${item1Res.data.ID},IsActiveEntity=false)`);

        const orderRes2 = await GET(`admin/Orders(ID=${orderId},IsActiveEntity=false)`);

        expect(Number(orderRes2.data.netAmount)).toBe(2 * BOOK_PRICE);
    });

    it('quantity above 10 is rejected', async () => {
        const orderRes = await POST('admin/Orders', {
            orderDate: '2026-01-15',
        });

        const orderId = orderRes.data.ID;

        const itemRes = await POST(`admin/Orders(ID=${orderId},IsActiveEntity=false)/items`, {
            book_ID: BOOK_ID,
            quantity: 3,
        });

        await expect(
            PATCH(`admin/OrderItems(ID=${itemRes.data.ID},IsActiveEntity=false)`, {
                quantity: 11,
            })
        ).rejects.toMatchObject({
            response: {
                status: 400,
            },
        });
    });

    it('quantity of exactly 10 is accepted', async () => {
        const orderRes = await POST('admin/Orders', {
            orderDate: '2026-01-15',
        });

        const orderId = orderRes.data.ID;

        const itemRes = await POST(`admin/Orders(ID=${orderId},IsActiveEntity=false)/items`, {
            book_ID: BOOK_ID,
            quantity: 3,
        });

        const res = await PATCH(`admin/OrderItems(ID=${itemRes.data.ID},IsActiveEntity=false)`, {
            quantity: 10,
        });

        expect(res.status).toBe(200);
    });
});
