import express from 'express';
import { router } from './routes';
const app = express();
app.use('/api', router);
app.listen(3002, () => {
  console.log("Listening on 3002");
});
