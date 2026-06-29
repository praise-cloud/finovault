import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { createTransactionSchema, updateTransactionSchema, transactionQuerySchema } from '../models/transaction.schema';
import { idParamSchema } from '../models/common.schema';
import * as transactionsController from '../controllers/transactions.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.get('/', validate({ query: transactionQuerySchema }), asyncWrap(transactionsController.listTransactions));
router.get('/:id', validate({ params: idParamSchema }), asyncWrap(transactionsController.getTransaction));
router.post('/', validate({ body: createTransactionSchema }), asyncWrap(transactionsController.createTransaction));
router.put('/:id', validate({ params: idParamSchema, body: updateTransactionSchema }), asyncWrap(transactionsController.updateTransaction));
router.delete('/:id', validate({ params: idParamSchema }), asyncWrap(transactionsController.deleteTransaction));

export default router;
