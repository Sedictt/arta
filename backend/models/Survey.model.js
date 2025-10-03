const mongoose = require('mongoose');

const surveySchema = new mongoose.Schema({
  // Demographics
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  clientType: {
    type: String,
    required: true,
    enum: ['Citizen', 'Business', 'Government']
  },
  sex: {
    type: String,
    required: true,
    enum: ['Male', 'Female']
  },
  age: {
    type: Number,
    required: true,
    min: 1,
    max: 150
  },
  region: {
    type: String,
    required: true,
    trim: true
  },
  
  // Citizen's Charter Awareness
  cc1Answer: {
    type: String,
    trim: true
  },
  cc2Answer: {
    type: String,
    trim: true
  },
  cc3Answer: {
    type: String,
    trim: true
  },
  
  // Service Quality Dimensions (SQD)
  sqdAnswers: {
    SQD0: { type: Number, min: 1, max: 5 },
    SQD1: { type: Number, min: 1, max: 5 },
    SQD2: { type: Number, min: 1, max: 5 },
    SQD3: { type: Number, min: 1, max: 5 },
    SQD4: { type: Number, min: 1, max: 5 },
    SQD5: { type: Number, min: 1, max: 5 },
    SQD6: { type: Number, min: 1, max: 5 },
    SQD7: { type: Number, min: 1, max: 5 },
    SQD8: { type: Number, min: 1, max: 5 }
  },
  
  // Suggestions
  suggestions: {
    type: String,
    trim: true,
    maxlength: 2000
  },
  
  // Metadata
  submittedAt: {
    type: Date,
    default: Date.now
  },
  ipAddress: {
    type: String
  },
  userAgent: {
    type: String
  }
}, {
  timestamps: true
});

// Virtual for average SQD score
surveySchema.virtual('averageSQDScore').get(function() {
  const scores = Object.values(this.sqdAnswers).filter(score => score != null);
  if (scores.length === 0) return 0;
  return scores.reduce((a, b) => a + b, 0) / scores.length;
});

// Virtual for satisfaction level
surveySchema.virtual('satisfactionLevel').get(function() {
  const avg = this.averageSQDScore;
  if (avg >= 4.5) return 'Very Satisfied';
  if (avg >= 3.5) return 'Satisfied';
  if (avg >= 2.5) return 'Neutral';
  if (avg >= 1.5) return 'Dissatisfied';
  return 'Very Dissatisfied';
});

// Ensure virtuals are included in JSON
surveySchema.set('toJSON', { virtuals: true });
surveySchema.set('toObject', { virtuals: true });

// Indexes for better query performance
surveySchema.index({ submittedAt: -1 });
surveySchema.index({ clientType: 1 });
surveySchema.index({ region: 1 });
surveySchema.index({ date: 1 });

const Survey = mongoose.model('Survey', surveySchema);

module.exports = Survey;
