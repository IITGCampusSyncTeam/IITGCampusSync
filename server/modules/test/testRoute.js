const express = require('express');
const router = express.Router();
const TestController = require('./testController');
const testController = new TestController();

router.get('/', (req, res) => {
    const data = testController.Test();
    res.json({ message: data, status: 1 });
});

router.post('/create', async (req, res) => {
    await testController.createTest(req, res);
});

router.get('/all', async (req, res) => {
    await testController.getAllTests(req, res);
});


module.exports = router;