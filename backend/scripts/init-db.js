const mongoose = require('mongoose');
const Admin = require('../models/Admin.model');
require('dotenv').config();

async function initializeDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(
      process.env.MONGODB_URI || 'mongodb://localhost:27017/arta_survey',
      {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      }
    );
    console.log('✅ Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ username: 'admin' });
    
    if (existingAdmin) {
      console.log('ℹ️  Default admin already exists');
      console.log('Username: admin');
      console.log('Use your existing password or change it via API');
    } else {
      // Create default admin
      const defaultAdmin = new Admin({
        username: 'admin',
        password: process.env.ADMIN_DEFAULT_PASSWORD || 'admin123',
        role: 'superadmin'
      });

      await defaultAdmin.save();
      console.log('✅ Default admin created successfully!');
      console.log('');
      console.log('=================================');
      console.log('Default Admin Credentials:');
      console.log('Username: admin');
      console.log('Password: admin123');
      console.log('=================================');
      console.log('');
      console.log('⚠️  IMPORTANT: Change the default password immediately!');
    }

    // Create indexes
    console.log('📊 Creating database indexes...');
    await mongoose.connection.db.collection('surveys').createIndex({ submittedAt: -1 });
    await mongoose.connection.db.collection('surveys').createIndex({ clientType: 1 });
    await mongoose.connection.db.collection('surveys').createIndex({ region: 1 });
    console.log('✅ Indexes created');

    console.log('');
    console.log('🎉 Database initialization complete!');
    console.log('');
    console.log('Next steps:');
    console.log('1. Start the server: npm start or npm run dev');
    console.log('2. Test the API: http://localhost:3000');
    console.log('3. Login with admin credentials');
    console.log('4. Change the default password');
    
  } catch (error) {
    console.error('❌ Error initializing database:', error);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('');
    console.log('Database connection closed');
    process.exit(0);
  }
}

// Run initialization
initializeDatabase();
