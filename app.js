// Module Tracker Application Logic
// Created: 2025-08-31 03:48:10
// Author: NjanyanaJayteeXaba

// Initialize Appwrite when document is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Appwrite client
    const client = new Appwrite.Client();
    client
        .setEndpoint(APPWRITE_CONFIG.endpoint)
        .setProject(APPWRITE_CONFIG.projectId);

    const databases = new Appwrite.Databases(client);

    // Keep the existing theme and UI functionality intact
    
    // Update login functionality with Appwrite
    const loginButton = document.getElementById('login-button');
    if (loginButton) {
        loginButton.addEventListener('click', async function() {
            // Simple validation (keep existing validation)
            const studentNumber = document.getElementById('student-number').value;
            const password = document.getElementById('password').value;
            
            if (!studentNumber || !password) {
                alert('Please enter both student number and password');
                return;
            }
            
            // Show loading state
            loginButton.disabled = true;
            loginButton.innerHTML = 'Logging in...';
            
            try {
                // Query database for user
                const response = await databases.listDocuments(
                    APPWRITE_CONFIG.databaseId,
                    APPWRITE_CONFIG.collections.users,
                    [
                        Appwrite.Query.equal('studentNumber', studentNumber)
                    ]
                );
                
                if (response.documents.length === 0) {
                    alert('Invalid student number or password');
                    return;
                }
                
                const user = response.documents[0];
                
                // Verify password (in production, use proper authentication)
                if (user.password === password) {
                    // Update lastLogin timestamp
                    const currentDate = new Date("2025-08-31 03:48:10");
                    await databases.updateDocument(
                        APPWRITE_CONFIG.databaseId, 
                        APPWRITE_CONFIG.collections.users,
                        user.$id,
                        { 
                            lastLogin: currentDate.toISOString() 
                        }
                    );
                    
                    // Store user info in session
                    const userInfo = {
                        id: user.$id,
                        studentNumber: user.studentNumber,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        yearOfStudy: user.yearOfStudy,
                        lastLogin: currentDate.toISOString()
                    };
                    
                    sessionStorage.setItem('currentUser', JSON.stringify(userInfo));
                    sessionStorage.setItem('loginTime', currentDate.toISOString());
                    sessionStorage.setItem('username', "NjanyanaJayteeXaba");
                    
                    // Redirect to dashboard
                    window.location.href = 'Module-Tracker-Dashboard.html';
                } else {
                    alert('Invalid student number or password');
                }
            } catch (error) {
                console.error('Login error:', error);
                alert('Login failed: ' + error.message);
            } finally {
                loginButton.disabled = false;
                loginButton.innerHTML = 'Log In';
            }
        });
    }

    // Update signup functionality with Appwrite
    const createAccountBtn = document.getElementById('create-account');
    if (createAccountBtn) {
        createAccountBtn.addEventListener('click', async function() {
            // Get form values (keep existing validation)
            const name = document.getElementById('signup-name').value;
            const studentNumber = document.getElementById('signup-student-number').value;
            const email = document.getElementById('signup-email').value;
            const password = document.getElementById('signup-password').value;
            const confirmPassword = document.getElementById('signup-confirm-password').value;
            
            // Simple validation (keep existing validation)
            if (!name || !studentNumber || !email || !password || !confirmPassword) {
                alert('Please fill all fields');
                return;
            }
            
            if (password !== confirmPassword) {
                alert('Passwords do not match');
                return;
            }
            
            if (password.length < 8) {
                alert('Password must be at least 8 characters');
                return;
            }
            
            if (!/^\d{9}$/.test(studentNumber)) {
                alert('Student number must be 9 digits');
                return;
            }
            
            // Show loading state
            createAccountBtn.disabled = true;
            createAccountBtn.innerHTML = 'Creating account...';
            
            try {
                // Check if student number already exists
                const response = await databases.listDocuments(
                    APPWRITE_CONFIG.databaseId,
                    APPWRITE_CONFIG.collections.users,
                    [
                        Appwrite.Query.equal('studentNumber', studentNumber)
                    ]
                );
                
                if (response.documents.length > 0) {
                    alert('Student number already registered');
                    return;
                }
                
                // Split name into first and last name
                const nameParts = name.split(' ');
                const firstName = nameParts[0];
                const lastName = nameParts.slice(1).join(' ');
                
                // Create new user document
                const currentDate = new Date("2025-08-31 03:48:10");
                await databases.createDocument(
                    APPWRITE_CONFIG.databaseId,
                    APPWRITE_CONFIG.collections.users,
                    'unique()',
                    {
                        studentNumber: studentNumber,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        password: password, // In production, use hashing
                        yearOfStudy: 1, // Default to 1st year
                        registrationDate: currentDate.toISOString(),
                        lastLogin: currentDate.toISOString()
                    }
                );
                
                // Show success message (keep existing success modal logic)
                document.getElementById('signup-modal').classList.add('hidden');
                document.getElementById('success-modal').classList.remove('hidden');
                
            } catch (error) {
                console.error('Signup error:', error);
                alert('Registration failed: ' + error.message);
            } finally {
                createAccountBtn.disabled = false;
                createAccountBtn.innerHTML = 'Create Account';
            }
        });
    }
});
