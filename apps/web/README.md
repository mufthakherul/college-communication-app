# RPI Web Dashboard

A web-based dashboard for the RPI Communication App. Currently supports teachers and administrators, with future support planned for students.

## Current Features (Teachers & Admins)

- 📊 **Dashboard Overview** - View statistics and analytics
- 👥 **User Management** - Create, edit, and manage users (students, teachers, admins)
- 📢 **Notice Management** - Create and manage announcements and notices
- 💬 **Message Monitoring** - View and monitor messages between users
- 🔐 **Secure Authentication** - Role-based access control

## Future Features (Students)

Planning to add:
- 📚 **Personal Dashboard** - View notices, assignments, and grades
- 💬 **Direct Messaging** - Chat with teachers and classmates
- 📖 **Course Materials** - Access study resources and books
- 📝 **Assignment Submission** - Submit homework and projects
- 📊 **Grade Tracking** - Monitor academic progress

## Tech Stack

- **React 19** - UI framework
- **TypeScript** - Type safety
- **Vite** - Fast build tool
- **Material-UI (MUI)** - UI components
- **React Router** - Client-side routing
- **Appwrite** - Backend as a Service
- **date-fns** - Date formatting

## Prerequisites

- Node.js 18 or higher
- npm or yarn
- Access to the Appwrite project (same as mobile app)

## Installation

1. Navigate to the web directory:
   ```bash
   cd apps/web
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

## Configuration

The app is pre-configured to use the same Appwrite backend as the mobile app. The configuration is located in:
- `src/config/appwrite.ts`

No additional configuration is needed if using the default setup.

## Development

Start the development server:

```bash
npm run dev
```

The app will be available at `http://localhost:3000`

## Building for Production

Build the application:

```bash
npm run build
```

The built files will be in the `dist` directory.

Preview the production build:

```bash
npm run preview
```

## Deployment

### 🚀 GitHub Actions Auto-Deploy (Recommended!)

**Best option**: Automatic deployment - your web app updates automatically when you edit the repository!

✅ **Already configured** - workflow included in `.github/workflows/deploy-web-dashboard.yml`  
✅ **Zero maintenance** - deploys automatically on every push  
✅ **Fast** - live in ~2 minutes after commit  
✅ **Live updates** - edit repo, changes go live automatically  

**Quick Setup** (2 minutes):

1. Choose Vercel or Netlify (sign in with GitHub)
2. Add 3 secrets to GitHub Settings → Secrets:
   - For **Vercel**: `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`
   - For **Netlify**: `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`
3. Done! Push changes and watch auto-deploy in Actions tab

**📖 Complete setup guide**: **[GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)** ⭐

---

### Alternative Options

#### Manual Deploy via Vercel/Netlify

1. Go to [vercel.com](https://vercel.com) or [netlify.com](https://netlify.com)
2. Sign in with GitHub
3. Import repository
4. Auto-configured, click Deploy
5. Manual re-deploy needed for updates

#### Deploy with CLI (Advanced)

For manual control or CI/CD pipelines:

**Appwrite:**
```bash
npm i -g appwrite-cli
appwrite login
cd apps/web && npm run build
appwrite deploy function
```

**Vercel:**
```bash
npm i -g vercel
cd apps/web && vercel
```

**Netlify:**
```bash
npm i -g netlify-cli
cd apps/web && netlify deploy --prod
```

### Documentation

- **[GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)** - ⭐ **Auto-deploy setup (recommended)**
- **[GITHUB_DEPLOYMENT.md](GITHUB_DEPLOYMENT.md)** - Deploy from GitHub (no CLI)
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide with all options

### Other Hosting Options

After building, upload the `dist` folder to any static hosting service:
- GitHub Pages
- AWS S3 + CloudFront
- Firebase Hosting
- Any web server (Apache, Nginx)

## Usage

### Login

1. Navigate to the app URL
2. Sign in with your teacher or admin credentials
3. Only users with `teacher` or `admin` role can access the dashboard

### Managing Users

1. Navigate to **Users** from the sidebar
2. Click **Add User** to create a new user
3. Click the edit icon to modify user details
4. Click the delete icon to remove a user

### Managing Notices

1. Navigate to **Notices** from the sidebar
2. Click **Create Notice** to publish a new notice
3. Set priority (high, medium, low) and department
4. Click the edit icon to modify existing notices
5. Click the delete icon to remove a notice

### Monitoring Messages

1. Navigate to **Messages** from the sidebar
2. View all messages exchanged between users
3. Monitor message status (read/unread)

## Project Structure

```
apps/web-teacher/
├── public/            # Static assets
├── src/
│   ├── components/    # Reusable components
│   │   └── Layout.tsx # Main layout with navigation
│   ├── config/        # Configuration files
│   │   └── appwrite.ts
│   ├── contexts/      # React contexts
│   │   └── AuthContext.tsx
│   ├── pages/         # Page components
│   │   ├── DashboardPage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── MessagesPage.tsx
│   │   ├── NoticesPage.tsx
│   │   └── UsersPage.tsx
│   ├── services/      # API services
│   │   ├── appwrite.service.ts
│   │   ├── message.service.ts
│   │   ├── notice.service.ts
│   │   └── user.service.ts
│   ├── types/         # TypeScript type definitions
│   │   └── index.ts
│   ├── App.tsx        # Main app component
│   └── main.tsx       # Entry point
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## Security

- Authentication is handled by Appwrite
- Role-based access control ensures only teachers and admins can access
- All API calls are authenticated with Appwrite sessions
- User sessions are managed securely

## Troubleshooting

### Cannot login
- Ensure your user has `teacher` or `admin` role in the Appwrite database
- Check that the Appwrite project ID and endpoint are correct
- Verify network connectivity to Appwrite server

### Data not loading
- Check browser console for errors
- Verify Appwrite database collections exist
- Ensure proper permissions are set on collections

### Build errors
- Clear `node_modules` and reinstall: `rm -rf node_modules && npm install`
- Check Node.js version: `node --version` (should be 18+)
- Run type check: `npm run lint`

## Contributing

When contributing to the teacher dashboard:
1. Follow the existing code structure
2. Use TypeScript for all new files
3. Follow Material-UI design patterns
4. Test thoroughly before committing

## License

MIT License - Same as the main project

## Support

For issues or questions:
- Check the main project documentation
- Review Appwrite documentation: https://appwrite.io/docs
- Open an issue on GitHub
