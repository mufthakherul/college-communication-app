/**
 * Features Page
 * Detailed features and guides for Campus Mesh
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
  AppBar,
  Toolbar,
  IconButton,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Chip,
} from '@mui/material';
import {
  ArrowBack,
  School,
  ExpandMore,
  Message,
  Notifications,
  Group,
  Event,
  Assignment,
  Security,
  CloudSync,
  QrCode,
  VideoCall,
  Search,
  Analytics,
  SmartToy,
} from '@mui/icons-material';

const FeaturesPage: React.FC = () => {
  const navigate = useNavigate();

  const features = [
    {
      icon: <Message sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Real-time Messaging',
      description: 'Instant messaging with individuals and groups. Support for text, images, files, and more.',
      roles: ['Students', 'Teachers', 'Admins'],
      highlights: [
        'One-on-one and group chats',
        'Media sharing (images, documents, files)',
        'Message read receipts',
        'Typing indicators',
        'Offline message queue',
      ],
    },
    {
      icon: <Notifications sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Notice Board',
      description: 'Digital notice board for announcements, events, and important updates.',
      roles: ['Teachers', 'Admins'],
      highlights: [
        'Create and publish notices',
        'Attach images and documents',
        'Schedule notices for later',
        'Target specific classes or departments',
        'Push notifications for new notices',
      ],
    },
    {
      icon: <Group sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'User Management',
      description: 'Comprehensive user management for students, teachers, and administrators.',
      roles: ['Admins'],
      highlights: [
        'Add/edit/delete users',
        'Role-based access control',
        'Batch user import',
        'User profiles and details',
        'Activity monitoring',
      ],
    },
    {
      icon: <Event sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Event Calendar',
      description: 'Keep track of college events, exams, holidays, and important dates.',
      roles: ['Students', 'Teachers', 'Admins'],
      highlights: [
        'View upcoming events',
        'Exam countdown timer',
        'Holiday calendar',
        'Event reminders',
        'Sync with device calendar',
      ],
    },
    {
      icon: <Assignment sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Assignment Tracker',
      description: 'Track assignments, submissions, and deadlines efficiently.',
      roles: ['Students', 'Teachers'],
      highlights: [
        'Assignment creation and distribution',
        'Submission tracking',
        'Deadline reminders',
        'Grade management',
        'Progress analytics',
      ],
    },
    {
      icon: <Security sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Security Features',
      description: 'Advanced security measures to protect your data and privacy.',
      roles: ['All Users'],
      highlights: [
        'End-to-end message encryption',
        'Biometric authentication',
        'Two-factor authentication',
        'Session management',
        'Secure data storage',
      ],
    },
    {
      icon: <QrCode sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'QR Code Tools',
      description: 'Generate and scan QR codes for quick information sharing.',
      roles: ['All Users'],
      highlights: [
        'QR code generator',
        'QR code scanner',
        'Share contact information',
        'Event check-in',
        'Quick profile sharing',
      ],
    },
    {
      icon: <VideoCall sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Video Calling',
      description: 'Built-in video calling for virtual classes and meetings.',
      roles: ['Teachers', 'Admins'],
      highlights: [
        'One-on-one video calls',
        'Group video meetings',
        'Screen sharing',
        'Chat during calls',
        'Call recording (with permission)',
      ],
    },
    {
      icon: <SmartToy sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'AI Chatbot',
      description: 'Intelligent AI assistant to help with common queries and support.',
      roles: ['All Users'],
      highlights: [
        'Powered by Google Gemini AI',
        'Answer college-related queries',
        'Get study help and resources',
        'Access college information',
        'Available 24/7',
      ],
    },
    {
      icon: <CloudSync sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Cloud Sync',
      description: 'Automatic cloud synchronization across all devices.',
      roles: ['All Users'],
      highlights: [
        'Real-time data sync',
        'Access from anywhere',
        'Automatic backups',
        'Offline mode support',
        'Cross-platform compatibility',
      ],
    },
    {
      icon: <Search sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Advanced Search',
      description: 'Powerful search to find messages, notices, and users quickly.',
      roles: ['All Users'],
      highlights: [
        'Global search',
        'Filter by type and date',
        'Search messages and notices',
        'User directory search',
        'Quick access to results',
      ],
    },
    {
      icon: <Analytics sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Analytics & Reports',
      description: 'Comprehensive analytics and reporting for administrators.',
      roles: ['Admins'],
      highlights: [
        'User activity analytics',
        'Message statistics',
        'Notice engagement metrics',
        'Performance monitoring',
        'Export reports (PDF, CSV)',
      ],
    },
  ];

  const guides = [
    {
      title: 'Getting Started',
      content: [
        'Download the Campus Mesh app for your role (Student/Teacher/Admin)',
        'Install the APK on your Android device',
        'Open the app and login with your credentials provided by the college',
        'Complete your profile setup',
        'Start exploring features!',
      ],
    },
    {
      title: 'Sending Messages',
      content: [
        'Tap on the Messages tab from the home screen',
        'Click the "+" button to start a new conversation',
        'Select a contact or create a group',
        'Type your message and hit send',
        'You can also send images, files, and other media',
      ],
    },
    {
      title: 'Creating Notices (Teachers/Admins)',
      content: [
        'Navigate to the Notices tab',
        'Click the "Create Notice" button',
        'Enter the notice title and description',
        'Add attachments if needed',
        'Select target audience (class, department, or all)',
        'Publish immediately or schedule for later',
      ],
    },
    {
      title: 'Using QR Code Features',
      content: [
        'Open the QR Code menu from tools',
        'Select "Generate QR" to create a QR code',
        'Choose the type of information to encode',
        'Share or save the generated QR code',
        'Use "Scan QR" to read QR codes',
      ],
    },
    {
      title: 'AI Chatbot Assistance',
      content: [
        'Tap on the AI Chat icon from the home screen',
        'Type your question or query',
        'The AI assistant will provide helpful responses',
        'Ask about college info, study help, or general queries',
        'View chat history for previous conversations',
      ],
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
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Features & Guides
          </Typography>
          <Typography variant="h6" component="h2">
            Everything you need to know about Campus Mesh
          </Typography>
        </Container>
      </Box>

      {/* Features Section */}
      <Container maxWidth="lg" sx={{ py: 6 }}>
        <Typography variant="h4" gutterBottom fontWeight="bold" color="primary" sx={{ mb: 4 }}>
          Complete Feature Set
        </Typography>
        <Grid container spacing={4} sx={{ mb: 6 }}>
          {features.map((feature, index) => (
            <Grid item xs={12} md={6} lg={4} key={index}>
              <Card
                sx={{
                  height: '100%',
                  display: 'flex',
                  flexDirection: 'column',
                  transition: 'transform 0.2s, box-shadow 0.2s',
                  '&:hover': {
                    transform: 'translateY(-8px)',
                    boxShadow: 6,
                  },
                }}
              >
                <CardContent sx={{ flexGrow: 1, p: 3 }}>
                  <Box sx={{ textAlign: 'center', mb: 2 }}>{feature.icon}</Box>
                  <Typography variant="h6" gutterBottom fontWeight="bold" align="center">
                    {feature.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary" paragraph>
                    {feature.description}
                  </Typography>
                  <Box sx={{ mb: 2 }}>
                    {feature.roles.map((role, idx) => (
                      <Chip
                        key={idx}
                        label={role}
                        size="small"
                        sx={{ mr: 0.5, mb: 0.5 }}
                        color="primary"
                        variant="outlined"
                      />
                    ))}
                  </Box>
                  <Typography variant="subtitle2" fontWeight="bold" gutterBottom>
                    Key Features:
                  </Typography>
                  <Box component="ul" sx={{ pl: 2, mt: 1, mb: 0 }}>
                    {feature.highlights.map((highlight, idx) => (
                      <Typography
                        component="li"
                        variant="body2"
                        color="text.secondary"
                        key={idx}
                        sx={{ mb: 0.5 }}
                      >
                        {highlight}
                      </Typography>
                    ))}
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* User Guides Section */}
        <Typography variant="h4" gutterBottom fontWeight="bold" color="primary" sx={{ mb: 3, mt: 6 }}>
          User Guides
        </Typography>
        <Box sx={{ mb: 4 }}>
          {guides.map((guide, index) => (
            <Accordion key={index} elevation={2}>
              <AccordionSummary expandIcon={<ExpandMore />}>
                <Typography variant="h6" fontWeight="bold">
                  {guide.title}
                </Typography>
              </AccordionSummary>
              <AccordionDetails>
                <Box component="ol" sx={{ pl: 2 }}>
                  {guide.content.map((step, idx) => (
                    <Typography
                      component="li"
                      variant="body1"
                      key={idx}
                      sx={{ mb: 1, lineHeight: 1.8 }}
                    >
                      {step}
                    </Typography>
                  ))}
                </Box>
              </AccordionDetails>
            </Accordion>
          ))}
        </Box>

        {/* CTA Section */}
        <Box sx={{ textAlign: 'center', py: 4, mt: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Ready to Experience Campus Mesh?
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Download the app now and start connecting with your college community
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap', mt: 3 }}>
            <Button
              variant="contained"
              size="large"
              onClick={() => navigate('/downloads')}
            >
              Download App
            </Button>
            <Button
              variant="outlined"
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

export default FeaturesPage;
