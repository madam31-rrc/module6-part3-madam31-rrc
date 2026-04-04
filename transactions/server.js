const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 4000;

app.use(cors());
app.use(express.json());

app.get('/transactions', (req, res) => {
    res.json({
        service: 'Pixel River Financial - Transactions Service',
        status: 'running',
        month: new Date().toISOString().slice(0, 7),
        message: 'Transactions microservice is operational',
        timestamp: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'Transactions service running on port 4000' });
});

app.listen(PORT, () => {
    console.log(`Transactions service running on port ${PORT}`);
});