const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Survey = require('../models/Survey.model');

// Validation middleware
const validateSurvey = [
  body('clientType').isIn(['Citizen', 'Business', 'Government']).withMessage('Invalid client type'),
  body('sex').isIn(['Male', 'Female']).withMessage('Invalid sex'),
  body('age').isInt({ min: 1, max: 150 }).withMessage('Age must be between 1 and 150'),
  body('region').trim().notEmpty().withMessage('Region is required'),
  body('suggestions').optional().trim().isLength({ max: 2000 }).withMessage('Suggestions too long')
];

// @route   POST /api/surveys
// @desc    Submit a new survey
// @access  Public
router.post('/', validateSurvey, async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    // Create survey
    const survey = new Survey({
      ...req.body,
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    });

    await survey.save();

    res.status(201).json({
      success: true,
      message: 'Survey submitted successfully',
      data: survey
    });
  } catch (error) {
    console.error('Error submitting survey:', error);
    res.status(500).json({
      success: false,
      message: 'Error submitting survey',
      error: error.message
    });
  }
});

// @route   GET /api/surveys
// @desc    Get all surveys (with pagination and filtering)
// @access  Admin only (add auth middleware in production)
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      clientType,
      region,
      startDate,
      endDate,
      sortBy = 'submittedAt',
      order = 'desc'
    } = req.query;

    // Build query
    const query = {};
    if (clientType) query.clientType = clientType;
    if (region) query.region = new RegExp(region, 'i');
    if (startDate || endDate) {
      query.submittedAt = {};
      if (startDate) query.submittedAt.$gte = new Date(startDate);
      if (endDate) query.submittedAt.$lte = new Date(endDate);
    }

    // Execute query with pagination
    const surveys = await Survey.find(query)
      .sort({ [sortBy]: order === 'desc' ? -1 : 1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const count = await Survey.countDocuments(query);

    res.json({
      success: true,
      data: surveys,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      totalRecords: count
    });
  } catch (error) {
    console.error('Error fetching surveys:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching surveys',
      error: error.message
    });
  }
});

// @route   GET /api/surveys/:id
// @desc    Get single survey by ID
// @access  Admin only
router.get('/:id', async (req, res) => {
  try {
    const survey = await Survey.findById(req.params.id);
    
    if (!survey) {
      return res.status(404).json({
        success: false,
        message: 'Survey not found'
      });
    }

    res.json({
      success: true,
      data: survey
    });
  } catch (error) {
    console.error('Error fetching survey:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching survey',
      error: error.message
    });
  }
});

// @route   DELETE /api/surveys/:id
// @desc    Delete a survey
// @access  Admin only
router.delete('/:id', async (req, res) => {
  try {
    const survey = await Survey.findByIdAndDelete(req.params.id);
    
    if (!survey) {
      return res.status(404).json({
        success: false,
        message: 'Survey not found'
      });
    }

    res.json({
      success: true,
      message: 'Survey deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting survey:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting survey',
      error: error.message
    });
  }
});

module.exports = router;
