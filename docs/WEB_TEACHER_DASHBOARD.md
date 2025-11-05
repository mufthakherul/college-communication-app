# Web Teacher Dashboard Guide

## Overview

The Web Teacher Dashboard is a comprehensive web application designed for teachers and administrators to monitor, manage, and control the RPI Communication App. It provides a modern, responsive interface for performing administrative tasks without requiring a mobile device.

## Features

### 1. Dashboard Overview
- Real-time statistics on users, notices, and messages
- Visual analytics with color-coded cards
- Quick insights into system activity

### 2. User Management
- View all users (students, teachers, admins)
- Create new user accounts
- Edit existing user information
- Deactivate or delete users
- Filter by role and department
- See user status (active/inactive)

### 3. Notice Management
- Create new notices and announcements
- Edit existing notices
- Set priority levels (high, medium, low)
- Target specific departments or broadcast to all
- Delete outdated notices
- View creation dates and authors

### 4. Message Monitoring
- View all messages sent between users
- Monitor message status (read/unread)
- Track communication patterns
- Identify potential issues

## Technology Stack

- **Frontend Framework**: React 19 with TypeScript
- **UI Library**: Material-UI (MUI) v6
- **Build Tool**: Vite for fast development and builds
- **Routing**: React Router v7
- **Backend**: Appwrite (same as mobile app)
- **Date Utilities**: date-fns
- **Charts**: Recharts (for future analytics)

## Architecture

### Project Structure

```
apps/web-teacher/
├── src/
│   ├── components/       # Reusable UI components
│   │   └── Layout.tsx   # Main layout with navigation
│   ├── config/          # Configuration files
│   │   └── appwrite.ts  # Appwrite connection config
│   ├── contexts/        # React contexts
│   │   └── AuthContext.tsx  # Authentication state management
│   ├── pages/          # Page components
│   │   ├── DashboardPage.tsx   # Main dashboard
│   │   ├── LoginPage.tsx       # Login page
│   │   ├── MessagesPage.tsx    # Message monitoring
│   │   ├── NoticesPage.tsx     # Notice management
│   │   └── UsersPage.tsx       # User management
│   ├── services/       # API services
│   │   ├── appwrite.service.ts    # Core Appwrite client
│   │   ├── message.service.ts     # Message operations
│   │   ├── notice.service.ts      # Notice operations
│   │   └── user.service.ts        # User operations
│   ├── types/          # TypeScript definitions
│   │   └── index.ts    # Shared type definitions
│   ├── App.tsx         # Main app with routing
│   └── main.tsx        # Application entry point
├── public/             # Static assets
├── dist/              # Build output (generated)
├── index.html         # HTML template
├── package.json       # Dependencies and scripts
├── tsconfig.json      # TypeScript configuration
└── vite.config.ts     # Vite build configuration
```

### Key Design Patterns

1. **Service Layer**: Separate services for each entity (users, notices, messages)
2. **Context API**: Centralized authentication state management
3. **Protected Routes**: Role-based access control
4. **Material Design**: Consistent UI following Material Design principles
5. **Responsive Design**: Works on desktop, tablet, and mobile browsers

## Setup Instructions

### Prerequisites

- Node.js 18 or higher
- npm or yarn
- Access to the Appwrite backend (same credentials as mobile app)

### Installation

1. Navigate to the web-teacher directory:
   ```bash
   cd apps/web-teacher
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. (Optional) Review configuration:
   - Configuration is in `src/config/appwrite.ts`
   - Should match mobile app settings

### Development

Start the development server:

```bash
npm run dev
```

The application will be available at `http://localhost:3000`

Features in development mode:
- Hot Module Replacement (HMR)
- Fast refresh
- Source maps for debugging
- TypeScript type checking

### Building for Production

Build the application:

```bash
npm run build
```

This will:
1. Run TypeScript type checking
2. Bundle and minify all code
3. Generate optimized assets
4. Create the `dist/` directory

Preview the production build:

```bash
npm run preview
```

## Deployment Options

### Option 1: Vercel (Recommended)

1. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

2. Deploy:
   ```bash
   cd apps/web-teacher
   vercel
   ```

3. Follow the prompts to complete deployment

Benefits:
- Automatic HTTPS
- Global CDN
- Zero configuration
- Free for personal projects

### Option 2: Netlify

1. Install Netlify CLI:
   ```bash
   npm i -g netlify-cli
   ```

2. Deploy:
   ```bash
   cd apps/web-teacher
   npm run build
   netlify deploy --prod
   ```

Benefits:
- Easy deployment
- Automatic form handling
- Built-in analytics
- Free tier available

### Option 3: GitHub Pages

1. Add to `package.json`:
   ```json
   "homepage": "https://yourusername.github.io/repo-name",
   "scripts": {
     "predeploy": "npm run build",
     "deploy": "gh-pages -d dist"
   }
   ```

2. Install gh-pages:
   ```bash
   npm install --save-dev gh-pages
   ```

3. Deploy:
   ```bash
   npm run deploy
   ```

### Option 4: Self-Hosted (Apache/Nginx)

After building, upload the `dist/` folder to your web server:

**Apache (.htaccess):**
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

**Nginx (nginx.conf):**
```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

## Usage Guide

### Initial Login

1. Navigate to the deployed URL
2. Enter your email and password
3. Click "Sign In"

**Important**: Only users with `teacher` or `admin` role can access the dashboard.

### Managing Users

#### Creating a User

1. Click "Users" in the sidebar
2. Click "Add User" button
3. Fill in the form:
   - Name (required)
   - Email (required)
   - Role (student/teacher/admin)
   - Department (optional)
4. Click "Save"

#### Editing a User

1. Find the user in the table
2. Click the edit (pencil) icon
3. Modify the fields
4. Click "Save"

#### Deleting a User

1. Find the user in the table
2. Click the delete (trash) icon
3. Confirm the deletion

### Managing Notices

#### Creating a Notice

1. Click "Notices" in the sidebar
2. Click "Create Notice" button
3. Fill in the form:
   - Title (required)
   - Content (required)
   - Department (optional - leave empty for all)
   - Priority (low/medium/high)
4. Click "Create"

#### Editing a Notice

1. Find the notice in the table
2. Click the edit icon
3. Modify the fields
4. Click "Update"

#### Deleting a Notice

1. Find the notice in the table
2. Click the delete icon
3. Confirm the deletion

### Monitoring Messages

1. Click "Messages" in the sidebar
2. View all messages in the system
3. Check message status (read/unread)
4. Monitor communication patterns

Note: Currently, messages can only be viewed, not edited or deleted from the web interface.

## Security Considerations

### Authentication
- Appwrite handles all authentication
- Sessions are stored securely
- Automatic session refresh

### Authorization
- Only teachers and admins can access
- Role checking on server side
- Client-side role verification

### Data Security
- All API calls go through Appwrite
- HTTPS recommended for production
- No sensitive data stored in client

### Best Practices

1. **Always use HTTPS in production**
2. **Never commit secrets to Git**
3. **Use strong passwords**
4. **Regularly update dependencies**
5. **Monitor Appwrite security logs**

## Troubleshooting

### Cannot Login

**Problem**: Login fails or redirects to login page

**Solutions**:
1. Check user role in Appwrite database
   - User must have `teacher` or `admin` role
2. Verify Appwrite credentials in `src/config/appwrite.ts`
3. Check browser console for errors
4. Ensure Appwrite server is accessible

### Data Not Loading

**Problem**: Dashboard shows no data or loading spinner indefinitely

**Solutions**:
1. Check browser console for errors
2. Verify Appwrite database collections exist:
   - `users`
   - `notices`
   - `messages`
3. Check collection permissions in Appwrite
4. Verify network connectivity
5. Check Appwrite API status

### Build Errors

**Problem**: Build fails with TypeScript or dependency errors

**Solutions**:
1. Delete `node_modules` and reinstall:
   ```bash
   rm -rf node_modules
   npm install
   ```
2. Check Node.js version (must be 18+):
   ```bash
   node --version
   ```
3. Clear npm cache:
   ```bash
   npm cache clean --force
   ```
4. Run type check to see specific errors:
   ```bash
   npm run lint
   ```

### Deployment Issues

**Problem**: App doesn't work after deployment

**Solutions**:
1. Ensure build was successful
2. Check that all assets are uploaded
3. Configure server for SPA routing (see deployment options)
4. Verify CORS settings in Appwrite
5. Add deployed domain to Appwrite platforms

## Future Enhancements

Planned features for future versions:

### Analytics Dashboard
- User activity charts
- Message statistics over time
- Notice engagement metrics
- Department-wise breakdowns

### Advanced User Management
- Bulk user import/export
- Password reset functionality
- Email notifications
- User activity logs

### Enhanced Notice Management
- Rich text editor for notices
- File attachments
- Scheduled publishing
- Notice templates

### Message Management
- Message filtering and search
- Conversation threads
- Message moderation tools
- Bulk actions

### System Settings
- App configuration
- Email templates
- Notification settings
- Backup and restore

### Mobile Responsiveness
- Optimized mobile views
- Touch-friendly interface
- Progressive Web App (PWA)
- Offline support

## Contributing

When contributing to the web dashboard:

1. Follow the existing code structure
2. Use TypeScript for all new files
3. Write clear, descriptive commit messages
4. Test thoroughly in multiple browsers
5. Update documentation as needed
6. Follow Material-UI design patterns
7. Maintain responsive design principles

## Support

For issues or questions:

- Review this documentation
- Check the main project README
- Review Appwrite documentation: https://appwrite.io/docs
- Open an issue on GitHub with:
  - Clear description of the problem
  - Steps to reproduce
  - Expected vs actual behavior
  - Screenshots if applicable

## License

MIT License - Same as the main project
