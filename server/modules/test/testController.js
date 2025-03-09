const Test = require('./testModel');

class TestController {
  

    async getAllTests(req, res) {
        try {
            const tests = await Test.find();
            res.status(200).json(tests);
        } catch (error) {
            res.status(500).json({ message: 'Error fetching tests', error });
        }
    }

    async createTest(req, res) {
        try {
            const { name, description } = req.body;
            const newTest = new Test({ name, description });
            await newTest.save();
            res.status(201).json(newTest);
        } catch (error) {
            res.status(500).json({ message: 'Error creating test', error });
        }
    }
}

module.exports = TestController;