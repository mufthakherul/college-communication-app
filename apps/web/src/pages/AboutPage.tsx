/**
 * About Page
 * Information about the RPI Echo System project
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
            RPI Echo System
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
            About RPI Echo System
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
            What is RPI Echo System?
          </Typography>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            RPI Echo System is a college communication platform that connects students, teachers, and
            administrators. It makes it easy to manage notices, messages, schedules, and more, all in
            one place.
          </Typography>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            Whether you're a student keeping up with announcements, a teacher managing classes, or an
            admin coordinating activities, RPI Echo System has everything you need to stay connected.
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
          Why RPI Echo System?
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
            Reliable & Secure
          </Typography>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            RPI Echo System uses modern, reliable technology to keep your data safe and the app running
            smoothly.
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  � Secure
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Your data is encrypted and protected
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  🔔 Real-time
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Get instant notifications
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  📱 Works Offline
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Access data without internet
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  ⚡ Fast
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Quick and responsive
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  � Cross-platform
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Works on mobile and web
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  🌐 Always Available
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  24/7 access to your data
                </Typography>
              </Box>
            </Grid>
          </Grid>
        </Paper>

          {/* Developer & Credits */}
          <Paper elevation={2} sx={{ p: 4, mb: 4 }}>
            <Typography variant="h4" gutterBottom fontWeight="bold" color="primary">
              Developer & Credits
            </Typography>
            <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
              <strong>Developer:</strong> Md Mufthakherul Islam Miraz
            </Typography>
            <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
              A full-stack developer passionate about creating solutions for education and communication.
              Check out more projects at{' '}
              <a
                href="https://www.mufthakherul.me"
                target="_blank"
                rel="noopener noreferrer"
                style={{ color: '#1976d2', textDecoration: 'none' }}
              >
                mufthakherul.me
              </a>
            </Typography>
          
            <Typography variant="h6" gutterBottom fontWeight="bold" sx={{ mt: 3 }}>
              Technical & Planning Support
            </Typography>
            <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
              <strong>Student Team:</strong> CST 2025-2026 Session, Day Shift, Group A
            </Typography>
            <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
              <strong>Guide Teacher:</strong> Alamgir Kabir<br />
              <strong>Email:</strong>{' '}
              <a
                href="mailto:md.kabir.cse@gmail.com"
                style={{ color: '#1976d2', textDecoration: 'none' }}
              >
                md.kabir.cse@gmail.com
              </a>
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mt: 2, fontStyle: 'italic' }}>
              Special thanks to all students and faculty who contributed ideas, feedback, and testing 
              to make RPI Echo System a reality.
            </Typography>
          </Paper>

        {/* CTA Section */}
        <Box sx={{ textAlign: 'center', py: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Ready to Get Started?
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Download the app or access the web dashboard to experience RPI Echo System
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
