import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import apiRoutes from './routes';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api', apiRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(port, () => {
  console.log(`Clash Companion Server is running on port ${port}`);
  if (!process.env.COC_API_KEY || process.env.COC_API_KEY === 'your_clash_developer_api_key') {
    console.log('WARNING: COC_API_KEY is not set. Using MOCK data mode.');
  }
});
