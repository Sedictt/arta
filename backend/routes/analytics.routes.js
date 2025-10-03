const express = require('express');
const router = express.Router();
const Survey = require('../models/Survey.model');

// @route   GET /api/analytics/summary
// @desc    Get overall analytics summary
// @access  Admin only
router.get('/summary', async (req, res) => {
  try {
    const totalResponses = await Survey.countDocuments();
    
    // Calculate average satisfaction
    const avgResult = await Survey.aggregate([
      {
        $project: {
          avgScore: {
            $avg: [
              '$sqdAnswers.SQD0', '$sqdAnswers.SQD1', '$sqdAnswers.SQD2',
              '$sqdAnswers.SQD3', '$sqdAnswers.SQD4', '$sqdAnswers.SQD5',
              '$sqdAnswers.SQD6', '$sqdAnswers.SQD7', '$sqdAnswers.SQD8'
            ]
          }
        }
      },
      {
        $group: {
          _id: null,
          overallAverage: { $avg: '$avgScore' }
        }
      }
    ]);

    const averageSatisfaction = avgResult.length > 0 
      ? avgResult[0].overallAverage.toFixed(2) 
      : 0;

    res.json({
      success: true,
      data: {
        totalResponses,
        averageSatisfaction: parseFloat(averageSatisfaction)
      }
    });
  } catch (error) {
    console.error('Error fetching summary:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching analytics summary',
      error: error.message
    });
  }
});

// @route   GET /api/analytics/satisfaction-distribution
// @desc    Get satisfaction level distribution
// @access  Admin only
router.get('/satisfaction-distribution', async (req, res) => {
  try {
    const surveys = await Survey.find().select('sqdAnswers');
    
    const distribution = {
      'Very Satisfied': 0,
      'Satisfied': 0,
      'Neutral': 0,
      'Dissatisfied': 0,
      'Very Dissatisfied': 0
    };

    surveys.forEach(survey => {
      const scores = Object.values(survey.sqdAnswers).filter(s => s != null);
      if (scores.length > 0) {
        const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
        
        if (avg >= 4.5) distribution['Very Satisfied']++;
        else if (avg >= 3.5) distribution['Satisfied']++;
        else if (avg >= 2.5) distribution['Neutral']++;
        else if (avg >= 1.5) distribution['Dissatisfied']++;
        else distribution['Very Dissatisfied']++;
      }
    });

    res.json({
      success: true,
      data: distribution
    });
  } catch (error) {
    console.error('Error fetching distribution:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching satisfaction distribution',
      error: error.message
    });
  }
});

// @route   GET /api/analytics/sqd-averages
// @desc    Get average scores for each SQD question
// @access  Admin only
router.get('/sqd-averages', async (req, res) => {
  try {
    const result = await Survey.aggregate([
      {
        $group: {
          _id: null,
          avgSQD0: { $avg: '$sqdAnswers.SQD0' },
          avgSQD1: { $avg: '$sqdAnswers.SQD1' },
          avgSQD2: { $avg: '$sqdAnswers.SQD2' },
          avgSQD3: { $avg: '$sqdAnswers.SQD3' },
          avgSQD4: { $avg: '$sqdAnswers.SQD4' },
          avgSQD5: { $avg: '$sqdAnswers.SQD5' },
          avgSQD6: { $avg: '$sqdAnswers.SQD7' },
          avgSQD7: { $avg: '$sqdAnswers.SQD7' },
          avgSQD8: { $avg: '$sqdAnswers.SQD8' }
        }
      }
    ]);

    const averages = result.length > 0 ? {
      SQD0: result[0].avgSQD0?.toFixed(2) || 0,
      SQD1: result[0].avgSQD1?.toFixed(2) || 0,
      SQD2: result[0].avgSQD2?.toFixed(2) || 0,
      SQD3: result[0].avgSQD3?.toFixed(2) || 0,
      SQD4: result[0].avgSQD4?.toFixed(2) || 0,
      SQD5: result[0].avgSQD5?.toFixed(2) || 0,
      SQD6: result[0].avgSQD6?.toFixed(2) || 0,
      SQD7: result[0].avgSQD7?.toFixed(2) || 0,
      SQD8: result[0].avgSQD8?.toFixed(2) || 0
    } : {};

    res.json({
      success: true,
      data: averages
    });
  } catch (error) {
    console.error('Error fetching SQD averages:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching SQD averages',
      error: error.message
    });
  }
});

// @route   GET /api/analytics/by-client-type
// @desc    Get statistics by client type
// @access  Admin only
router.get('/by-client-type', async (req, res) => {
  try {
    const result = await Survey.aggregate([
      {
        $group: {
          _id: '$clientType',
          count: { $sum: 1 },
          avgSatisfaction: {
            $avg: {
              $avg: [
                '$sqdAnswers.SQD0', '$sqdAnswers.SQD1', '$sqdAnswers.SQD2',
                '$sqdAnswers.SQD3', '$sqdAnswers.SQD4', '$sqdAnswers.SQD5',
                '$sqdAnswers.SQD6', '$sqdAnswers.SQD7', '$sqdAnswers.SQD8'
              ]
            }
          }
        }
      },
      {
        $sort: { count: -1 }
      }
    ]);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error fetching client type stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching client type statistics',
      error: error.message
    });
  }
});

// @route   GET /api/analytics/by-region
// @desc    Get statistics by region
// @access  Admin only
router.get('/by-region', async (req, res) => {
  try {
    const result = await Survey.aggregate([
      {
        $group: {
          _id: '$region',
          count: { $sum: 1 },
          avgSatisfaction: {
            $avg: {
              $avg: [
                '$sqdAnswers.SQD0', '$sqdAnswers.SQD1', '$sqdAnswers.SQD2',
                '$sqdAnswers.SQD3', '$sqdAnswers.SQD4', '$sqdAnswers.SQD5',
                '$sqdAnswers.SQD6', '$sqdAnswers.SQD7', '$sqdAnswers.SQD8'
              ]
            }
          }
        }
      },
      {
        $sort: { count: -1 }
      }
    ]);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error fetching region stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching region statistics',
      error: error.message
    });
  }
});

// @route   GET /api/analytics/trends
// @desc    Get response trends over time
// @access  Admin only
router.get('/trends', async (req, res) => {
  try {
    const { days = 30 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const result = await Survey.aggregate([
      {
        $match: {
          submittedAt: { $gte: startDate }
        }
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$submittedAt' }
          },
          count: { $sum: 1 },
          avgSatisfaction: {
            $avg: {
              $avg: [
                '$sqdAnswers.SQD0', '$sqdAnswers.SQD1', '$sqdAnswers.SQD2',
                '$sqdAnswers.SQD3', '$sqdAnswers.SQD4', '$sqdAnswers.SQD5',
                '$sqdAnswers.SQD6', '$sqdAnswers.SQD7', '$sqdAnswers.SQD8'
              ]
            }
          }
        }
      },
      {
        $sort: { _id: 1 }
      }
    ]);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error fetching trends:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching trends',
      error: error.message
    });
  }
});

// @route   GET /api/analytics/export
// @desc    Export all survey data as JSON
// @access  Admin only
router.get('/export', async (req, res) => {
  try {
    const surveys = await Survey.find().sort({ submittedAt: -1 });
    
    res.json({
      success: true,
      count: surveys.length,
      data: surveys,
      exportedAt: new Date()
    });
  } catch (error) {
    console.error('Error exporting data:', error);
    res.status(500).json({
      success: false,
      message: 'Error exporting data',
      error: error.message
    });
  }
});

module.exports = router;
