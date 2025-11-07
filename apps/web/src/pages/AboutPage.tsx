/**
 * About Page
 * Information about the Campus Mesh project
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
  Paper,
  AppBar,
  Toolbar,
  IconButton,
} from '@mui/material';
import {
  ArrowBack,
  School,
  Group,
  Speed,
  Lock,
  CloudSync,
  Chat,
} from '@mui/icons-material';

const AboutPage: React.FC = () => {
  const navigate = useNavigate();

  const benefits = [
    {
      icon: <Group sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'For Everyone',
      description: 'Dedicated interfaces for Students, Teachers, and Administrators with role-based features.',
    },
    {
      icon: <Speed sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Fast & Efficient',
      description: 'Optimized performance for quick access to messages, notices, and schedules.',
    },
    {
      icon: <Lock sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Secure & Private',
      description: 'Your data is protected with modern encryption and security practices.',
    },
    {
      icon: <CloudSync sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Always in Sync',
      description: 'Cloud-based synchronization ensures your data is always up-to-date.',
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
            About Campus Mesh
          </Typography>
          <Typography variant="h6" component="h2">
            Revolutionizing College Communication
          </Typography>
        </Container>
      </Box>

      {/* Main Content */}
      <Container maxWidth="lg" sx={{ py: 6 }}>
        {/* Overview */}
        <Paper elevation={2} sx={{ p: 4, mb: 4 }}>
          <Typography variant="h4" gutterBottom fontWeight="bold" color="primary">
            What is Campus Mesh?
          </Typography>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            Campus Mesh is a comprehensive college communication platform designed to bridge the gap
            between students, teachers, and administrators. Built with modern technology and security
            in mind, it provides a seamless experience for managing notices, messages, schedules, and
            more.
          </Typography>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            Whether you're a student staying updated with college announcements, a teacher managing
            classes and assignments, or an administrator coordinating campus activities, Campus Mesh
            offers tailored solutions for everyone.
          </Typography>
        </Paper>

        {/* Mission & Vision */}
        <Grid container spacing={4} sx={{ mb: 4 }}>
          <Grid item xs={12} md={6}>
            <Card sx={{ height: '100%', bgcolor: '#e3f2fd' }}>
              <CardContent sx={{ p: 4 }}>
                <Typography variant="h5" gutterBottom fontWeight="bold" color="primary">
                  Our Mission
                </Typography>
                <Typography variant="body1" sx={{ lineHeight: 1.8 }}>
                  To simplify and enhance communication within educational institutions by providing
                  a secure, reliable, and user-friendly platform that connects the entire college
                  community.
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={6}>
            <Card sx={{ height: '100%', bgcolor: '#f3e5f5' }}>
              <CardContent sx={{ p: 4 }}>
                <Typography variant="h5" gutterBottom fontWeight="bold" color="secondary">
                  Our Vision
                </Typography>
                <Typography variant="body1" sx={{ lineHeight: 1.8 }}>
                  To become the go-to communication platform for colleges and universities,
                  fostering better engagement, transparency, and collaboration across educational
                  communities.
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Key Benefits */}
        <Typography variant="h4" gutterBottom fontWeight="bold" color="primary" sx={{ mb: 4 }}>
          Why Campus Mesh?
        </Typography>
        <Grid container spacing={4} sx={{ mb: 4 }}>
          {benefits.map((benefit, index) => (
            <Grid item xs={12} sm={6} md={3} key={index}>
              <Card
                sx={{
                  height: '100%',
                  textAlign: 'center',
                  transition: 'transform 0.2s',
                  '&:hover': {
                    transform: 'translateY(-8px)',
                    boxShadow: 4,
                  },
                }}
              >
                <CardContent sx={{ p: 3 }}>
                  <Box sx={{ mb: 2 }}>{benefit.icon}</Box>
                  <Typography variant="h6" gutterBottom fontWeight="bold">
                    {benefit.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {benefit.description}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* Technology Stack */}
        <Paper elevation={2} sx={{ p: 4, mb: 4 }}>
          <Typography variant="h4" gutterBottom fontWeight="bold" color="primary">
            Built with Modern Technology
          </Typography>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            Campus Mesh is built using cutting-edge technologies to ensure reliability, security,
            and performance:
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  🚀 Flutter
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Cross-platform mobile app development
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  ⚛️ React
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Modern web dashboard interface
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  ☁️ Appwrite
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Backend-as-a-Service platform
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  🔒 End-to-End Encryption
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Secure message encryption
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  🔔 Real-time Notifications
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Instant push notifications
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  📱 Offline Support
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Access data without internet
                </Typography>
              </Box>
            </Grid>
          </Grid>
        </Paper>

        {/* CTA Section */}
        <Box sx={{ textAlign: 'center', py: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Ready to Get Started?
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Download the app or access the web dashboard to experience Campus Mesh
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
              onClick={() => navigate('/features')}
            >
              Explore Features
            </Button>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default AboutPage;
