# RPI Communication App

A comprehensive college communication platform for **Rangpur Polytechnic Institute** built with Flutter and Supabase.

🌐 **College Website:** [rangpur.polytech.gov.bd](https://rangpur.polytech.gov.bd)  
👨‍💻 **Developed by:** Mufthakherul

> ⚠️ **IMPORTANT:** The app code is complete, but requires Supabase setup to work. See [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md) for connection instructions.

> 💰 **COST-FREE:** Migrated from Firebase to Supabase to eliminate monthly charges! Supabase free tier is generous enough for college use.

> 💡 **NEW:** Try **Demo Mode** to explore the app without Supabase! See demo mode button on login screen.

> 🌐 **NEW:** **Mesh Network** feature enables peer-to-peer communication via Bluetooth/WiFi Direct - works even without internet! See [MESH_NETWORK_GUIDE.md](MESH_NETWORK_GUIDE.md) for details.

> 🔒 **Security:** Demo mode is safe and isolated. See [DEMO_MODE_SECURITY.md](DEMO_MODE_SECURITY.md) for details.

> 📖 **For Teachers:** See [QUICK_START.md](QUICK_START.md) for immediate APK download and review  
> 📖 **For Details:** See [TEACHER_GUIDE.md](TEACHER_GUIDE.md) for complete instructions

## 🚀 Supabase Connection Required

The app needs to be connected to Supabase to function. Follow the step-by-step guide: [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md)

**What Supabase Provides (100% Free):**
- User authentication (login/register) - 50,000 monthly active users
- PostgreSQL database for notices and messages - 500 MB storage
- File storage for images and documents - 1 GB storage
- Edge functions for backend logic - 500,000 invocations/month
- Real-time subscriptions - Unlimited connections

**Why Supabase?**
- **Zero cost** for typical college usage
- More generous free tier than Firebase
- Open source and self-hostable
- PostgreSQL instead of NoSQL (more powerful queries)

## 📱 Download APK

**For Teachers/Students:** Download the latest APK to install on your Android device:

1. Go to [Actions → Latest Build](../../actions/workflows/build-apk.yml)
2. Download the APK artifact from the latest successful run
3. Or check the [Releases Page](../../releases) for stable versions

See the complete [APK Build Guide](APK_BUILD_GUIDE.md) for detailed instructions.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/mufthakherul/college-communication-app.git
cd college-communication-app

# Set up development environment
./scripts/setup-dev.sh

# Run the mobile app
cd apps/mobile
flutter run
```

## ✨ Key Features

### Core Features
- 📢 **Notices & Announcements** - Share important information with students and faculty
- 💬 **Direct Messaging** - Real-time communication between users
- 👤 **Role-Based Access** - Admin, Teacher, and Student roles
- 🔐 **Secure Authentication** - Supabase Authentication with email/password
- 🌙 **Dark Mode** - Eye-friendly theme support
- 🔍 **Full-Text Search** - 🆕 Fast PostgreSQL search with relevance ranking
- 📝 **Markdown Support** - Rich text formatting in notices

### Advanced Features
- 🌐 **Mesh Network** - Peer-to-peer communication via Bluetooth/WiFi Direct
  - Works without internet or cellular service
  - Automatic peer discovery and connection
  - Emergency communication mode
- 📡 **Smart Offline Mode** - Automatic queue and sync
  - Retry logic with exponential backoff
  - Priority-based action queue (max 100)
  - Background sync every 15 minutes
- 💾 **Intelligent Caching** - Fast and efficient data access
  - Time-based expiry (5min, 1hr, 1day)
  - 50MB cache limit with auto-cleanup
  - GZip compression support
- 🔄 **Conflict Resolution** - Handle simultaneous edits
  - Multiple resolution strategies
  - Optimistic locking
  - Version tracking
- 📊 **Network Monitoring** - Real-time connection status
  - Network quality detection
  - Connectivity indicators
  - Sync statistics

### Enterprise Features 🆕
- ⚡ **Edge Functions** - Serverless backend with Supabase Edge Functions
  - User activity tracking
  - Analytics report generation
  - Batch notifications
- 📈 **Analytics & Monitoring** - Comprehensive analytics system
  - User activity tracking
  - Admin analytics dashboard
  - Performance monitoring
  - Real-time metrics
- 🔍 **Full-Text Search** - PostgreSQL-powered search
  - Weighted relevance ranking
  - Search suggestions
  - 10x faster than basic search
- ⚡ **Performance Monitoring** - Built-in performance tracking
  - Operation duration tracking
  - Slow operation detection
  - Performance statistics (avg, p95, etc.)
- 🛡️ **Crash Reporting** - Integration ready (Sentry)
- 📱 **Push Notifications** - Integration ready (OneSignal)
- 💾 **Data Backup** - Automated backup helpers
- 🚀 **10x Performance** - Optimized with indexes and materialized views

## 📖 Documentation

### Setup & Getting Started
- [Supabase Setup Guide](SUPABASE_SETUP_GUIDE.md) - **🆕 Connect to Supabase (start here!)**
- [APK Build Guide](APK_BUILD_GUIDE.md) - **Download and install the app**
- [Quick Start](QUICK_START.md) - **For teachers/immediate use**

### Advanced Features (Phase 2 & 3)
- [Phase 2 & 3 Implementation](PHASE2_PHASE3_IMPLEMENTATION.md) - **🆕 Complete feature overview**
- [Edge Functions Guide](EDGE_FUNCTIONS_GUIDE.md) - **🆕 Serverless functions deployment**
- [Analytics Setup Guide](ANALYTICS_SETUP_GUIDE.md) - **🆕 Analytics, Sentry, OneSignal**

### Technical Documentation
- [Mesh Network Guide](MESH_NETWORK_GUIDE.md) - **Peer-to-peer communication**
- [Network Improvements Summary](NETWORK_IMPROVEMENTS_SUMMARY.md) - **Technical details**
- [Complete Networking Guide](NETWORKING_COMPLETE_GUIDE.md) - **🆕 Comprehensive networking documentation**
- [Networking Troubleshooting](NETWORKING_TROUBLESHOOTING.md) - **🆕 Solve networking issues**
- [Full Documentation](docs/README.md)
- [Architecture Overview](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Database Seeding Guide](docs/SEEDING.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

### Migration & Reference
- [Migration Notes](MIGRATION_NOTES.md) - **Complete migration documentation**
- [Firebase Setup Guide](FIREBASE_SETUP_GUIDE.md) - **Legacy reference**

## 🏗️ Project Structure

```
├── apps/mobile/          # Flutter mobile application
├── backend/             # Backend utilities and scripts
├── functions/           # Cloud Functions (legacy Firebase, can be migrated to Supabase Edge Functions)
├── infra/              # Infrastructure configuration (includes Supabase SQL schema)
├── scripts/            # Build and deployment scripts
├── docs/              # Documentation
├── firebase.json      # Firebase configuration (legacy, for reference)
└── README.md         # This file
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](docs/CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License.