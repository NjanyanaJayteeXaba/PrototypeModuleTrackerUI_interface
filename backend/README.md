# CPUT Module Tracker (Term 3 Minimal)

# CPUT Module Tracker

A prototype UI interface for tracking modules, assignments, and grades for CPUT students.

## Project Overview

This web application allows students to:
- View their enrolled modules
- Track upcoming assignments and due dates
- Monitor their grades and academic progress
- Access module-specific information

## Getting Started

### Prerequisites
- Appwrite account and project setup
- Web server or hosting service

### Configuration

**Important Security Note**: This project uses Appwrite for backend services. You need to create a secure configuration file before running the application.

1. Copy the template config file:
```
cp config.template.js config.js
```

2. Open `config.js` and replace the placeholder values with your actual Appwrite credentials:
```javascript
const APPWRITE_CONFIG = {
    endpoint: 'https://cloud.appwrite.io/v1',
    projectId: 'YOUR_PROJECT_ID',  // Replace with your Appwrite project ID
    databaseId: 'YOUR_DATABASE_ID', // Replace with your database ID
    collections: {
        users: 'users',
        modules: 'modules',
        assignments: 'assignments',
        grades: 'grades'
    }
};
```

3. **NEVER commit the `config.js` file to git!** It has already been added to `.gitignore`.

### Running the Application

1. Open `index.html` in your browser
2. Login with your student number and password
3. Navigate through the different sections to view your academic information

## Database Structure

The application uses the following Appwrite collections:
- `users`: Student information and authentication details
- `modules`: Information about academic modules
- `assignments`: Assignment details including due dates
- `grades`: Student grades for assignments and exams

## Development Notes

- Last updated: 2025-08-31 03:20:57
- Current maintainer: NjanyanaJayteeXaba

## Security Considerations

- Always keep your Appwrite credentials private
- Use proper authentication for all database operations
- Follow the principle of least privilege when setting up collection permissions

## License

This project is licensed under the MIT License - see the LICENSE file for details.
