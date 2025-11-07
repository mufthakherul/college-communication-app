/**
 * Downloads Page
 * APK downloads for different user roles
 */

import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Button,
  Grid,
  Card,
  CardContent,
  CardActions,
  AppBar,
  Toolbar,
  IconButton,
  Chip,
  Alert,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material';
import {
  ArrowBack,
  School,
  Download,
  Android,
  Person,
  Engineering,
  AdminPanelSettings,
  CheckCircle,
  Warning,
  Info,
} from '@mui/icons-material';

const DownloadsPage: React.FC = () => {
  const navigate = useNavigate();

  const apps = [
    {
      icon: <Person sx={{ fontSize: 60, color: '#2196f3' }} />,
      title: 'Student App',
      description: 'For students to access messages, notices, assignments, and more.',
      version: 'v2.1.0',
      size: '~45 MB',
      color: '#2196f3',
      features: [
        'View and respond to messages',
        'Access notice board',
        'Track assignments and deadlines',
        'Use AI chatbot for help',
        'QR code tools',
        'Event calendar',
      ],
      requirements: 'Android 5.0 (Lollipop) or higher',
      downloadLink: '#', // Replace with actual link
    },
    {
      icon: <Engineering sx={{ fontSize: 60, color: '#4caf50' }} />,
      title: 'Teacher App',
      description: 'For teachers to manage classes, create notices, and communicate with students.',
      version: 'v2.1.0',
      size: '~45 MB',
      color: '#4caf50',
      features: [
        'Create and publish notices',
        'Send messages to students',
        'Manage assignments',
        'Conduct video classes',
        'Track student attendance',
        'Analytics and reports',
      ],
      requirements: 'Android 5.0 (Lollipop) or higher',
      downloadLink: '#', // Replace with actual link
    },
    {
      icon: <AdminPanelSettings sx={{ fontSize: 60, color: '#ff9800' }} />,
      title: 'Admin App',
      description: 'For administrators to manage users, oversee operations, and access analytics.',
      version: 'v2.1.0',
      size: '~45 MB',
      color: '#ff9800',
      features: [
        'Complete user management',
        'System-wide announcements',
        'Advanced analytics',
        'Role and permission management',
        'Monitoring and reporting',
        'Full administrative control',
      ],
      requirements: 'Android 5.0 (Lollipop) or higher',
      downloadLink: '#', // Replace with actual link
    },
  ];

  const installSteps = [
    {
      title: 'Enable Unknown Sources',
      description: 'Go to Settings > Security > Enable "Install from Unknown Sources" or "Install Unknown Apps"',
    },
    {
      title: 'Download APK',
      description: 'Click the download button for your role (Student/Teacher/Admin)',
    },
    {
      title: 'Install the App',
      description: 'Open the downloaded APK file and tap "Install"',
    },
    {
      title: 'Open and Login',
      description: 'Launch Campus Mesh and login with your credentials',
    },
  ];

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: 'grey.50' }}>
      {/* Header */}
      <AppBar position="static">
        <Toolbar>
          <IconButton
            edge="start"
            color="inherit"
            onClick={() => navigate('/')}
            sx={{ mr: 2 }}
          >
            <ArrowBack />
          </IconButton>
          <School sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Campus Mesh
          </Typography>
          <Button color="inherit" onClick={() => navigate('/login')}>
            Login
          </Button>
        </Toolbar>
      </AppBar>

      {/* Hero Section */}
      <Box
        sx={{
          bgcolor: 'primary.main',
          color: 'white',
          py: 8,
          textAlign: 'center',
        }}
      >
        <Container maxWidth="md">
          <Download sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Download Campus Mesh
          </Typography>
          <Typography variant="h6" component="h2">
            Get the app for your role - Available for Android
          </Typography>
        </Container>
      </Box>

      {/* Important Notice */}
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="info" icon={<Info />} sx={{ mb: 4 }}>
          <Typography variant="body1" fontWeight="bold" gutterBottom>
            Important: Choose the Right App
          </Typography>
          <Typography variant="body2">
            Make sure to download the app corresponding to your role. Students should download the
            Student App, Teachers the Teacher App, and Administrators the Admin App. Each app has
            role-specific features and access levels.
          </Typography>
        </Alert>
      </Container>

      {/* Download Cards */}
      <Container maxWidth="lg" sx={{ py: 4 }}>
        <Grid container spacing={4} sx={{ mb: 6 }}>
          {apps.map((app, index) => (
            <Grid item xs={12} md={4} key={index}>
              <Card
                sx={{
                  height: '100%',
                  display: 'flex',
                  flexDirection: 'column',
                  borderTop: `4px solid ${app.color}`,
                  transition: 'transform 0.2s, box-shadow 0.2s',
                  '&:hover': {
                    transform: 'translateY(-8px)',
                    boxShadow: 6,
                  },
                }}
              >
                <CardContent sx={{ flexGrow: 1, textAlign: 'center' }}>
                  <Box sx={{ mb: 2 }}>{app.icon}</Box>
                  <Typography variant="h5" gutterBottom fontWeight="bold">
                    {app.title}
                  </Typography>
                  <Box sx={{ mb: 2 }}>
                    <Chip label={app.version} size="small" color="primary" sx={{ mr: 1 }} />
                    <Chip label={app.size} size="small" variant="outlined" />
                  </Box>
                  <Typography variant="body2" color="text.secondary" paragraph>
                    {app.description}
                  </Typography>
                  <Typography
                    variant="subtitle2"
                    fontWeight="bold"
                    gutterBottom
                    align="left"
                    sx={{ mt: 2 }}
                  >
                    Key Features:
                  </Typography>
                  <Box component="ul" sx={{ textAlign: 'left', pl: 2, pr: 0 }}>
                    {app.features.map((feature, idx) => (
                      <Typography
                        component="li"
                        variant="body2"
                        color="text.secondary"
                        key={idx}
                        sx={{ mb: 0.5 }}
                      >
                        {feature}
                      </Typography>
                    ))}
                  </Box>
                  <Alert severity="success" icon={<Android />} sx={{ mt: 2, textAlign: 'left' }}>
                    <Typography variant="caption">
                      <strong>Requirements:</strong> {app.requirements}
                    </Typography>
                  </Alert>
                </CardContent>
                <CardActions sx={{ p: 2, pt: 0 }}>
                  <Button
                    variant="contained"
                    fullWidth
                    size="large"
                    startIcon={<Download />}
                    sx={{ bgcolor: app.color, '&:hover': { bgcolor: app.color, opacity: 0.9 } }}
                    onClick={() => {
                      // In production, this would trigger the actual download
                      alert(
                        `Download for ${app.title} will start soon.\n\nIn production, this will download the APK file.`
                      );
                    }}
                  >
                    Download APK
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* Installation Guide */}
        <Box sx={{ mb: 6 }}>
          <Typography variant="h4" gutterBottom fontWeight="bold" color="primary">
            Installation Guide
          </Typography>
          <Card elevation={2} sx={{ mt: 3 }}>
            <CardContent sx={{ p: 4 }}>
              <List>
                {installSteps.map((step, index) => (
                  <ListItem key={index} alignItems="flex-start" sx={{ mb: 1 }}>
                    <ListItemIcon>
                      <Box
                        sx={{
                          width: 32,
                          height: 32,
                          borderRadius: '50%',
                          bgcolor: 'primary.main',
                          color: 'white',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontWeight: 'bold',
                        }}
                      >
                        {index + 1}
                      </Box>
                    </ListItemIcon>
                    <ListItemText
                      primary={
                        <Typography variant="h6" fontWeight="bold">
                          {step.title}
                        </Typography>
                      }
                      secondary={
                        <Typography variant="body1" color="text.secondary" sx={{ mt: 0.5 }}>
                          {step.description}
                        </Typography>
                      }
                    />
                  </ListItem>
                ))}
              </List>
            </CardContent>
          </Card>
        </Box>

        {/* Security Notice */}
        <Alert severity="warning" icon={<Warning />} sx={{ mb: 4 }}>
          <Typography variant="body1" fontWeight="bold" gutterBottom>
            Security Notice
          </Typography>
          <Typography variant="body2">
            Only download Campus Mesh from this official website. Do not install APK files from
            untrusted sources. If you encounter any issues during installation, please contact your
            college administrator or visit the support section.
          </Typography>
        </Alert>

        {/* Additional Info */}
        <Box sx={{ textAlign: 'center', py: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Need Help?
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Check out our features guide for detailed instructions on using the app
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap', mt: 3 }}>
            <Button
              variant="outlined"
              size="large"
              onClick={() => navigate('/features')}
            >
              View Features & Guides
            </Button>
            <Button
              variant="text"
              size="large"
              onClick={() => navigate('/about')}
            >
              Learn More
            </Button>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default DownloadsPage;
