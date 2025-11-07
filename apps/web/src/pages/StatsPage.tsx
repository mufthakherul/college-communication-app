/**
 * Statistics Page
 * Platform usage statistics for RPI Echo System
 */

import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  Chip,
} from '@mui/material';
import {
  TrendingUp,
  People,
  Message,
  Announcement,
  Group,
} from '@mui/icons-material';
import Navigation from '../components/Navigation';

const StatsPage: React.FC = () => {
  const navigate = useNavigate();

  const stats = [
    {
      icon: <People sx={{ fontSize: 60, color: '#2196f3' }} />,
      label: 'Total Users',
      value: '2,450+',
      description: 'Active community members',
    },
    {
      icon: <Group sx={{ fontSize: 60, color: '#4caf50' }} />,
      label: 'Daily Active',
      value: '1,200+',
      description: 'Users every day',
    },
    {
      icon: <Message sx={{ fontSize: 60, color: '#ff9800' }} />,
      label: 'Messages',
      value: '45,000+',
      description: 'Conversations happening',
    },
    {
      icon: <Announcement sx={{ fontSize: 60, color: '#9c27b0' }} />,
      label: 'Notices',
      value: '230+',
      description: 'Important announcements',
    },
  ];

  const departments = [
    'Computer Science & Engineering',
    'Electronics & Communication',
    'Electrical Engineering',
    'Civil Engineering',
    'Mechanical Engineering',
  ];

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: 'grey.50' }}>
      <Navigation />

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
          <TrendingUp sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Platform Stats
          </Typography>
          <Typography variant="h6" component="h2">
            See how our community is growing
          </Typography>
          <Chip
            label="Updated Daily"
            sx={{ mt: 2, bgcolor: 'white', color: 'primary.main', fontWeight: 'bold' }}
          />
        </Container>
      </Box>

      {/* Main Stats */}
      <Container maxWidth="lg" sx={{ py: 6 }}>
        <Grid container spacing={3}>
          {stats.map((stat, index) => (
            <Grid item xs={12} sm={6} md={3} key={index}>
              <Card elevation={3}>
                <CardContent sx={{ textAlign: 'center' }}>
                  {stat.icon}
                  <Typography variant="h4" fontWeight="bold" color="primary" sx={{ mt: 2 }}>
                    {stat.value}
                  </Typography>
                  <Typography variant="h6" fontWeight="medium" gutterBottom>
                    {stat.label}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {stat.description}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* Departments */}
        <Box sx={{ mt: 6 }}>
          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mb: 3 }}>
            Active Departments
          </Typography>
          <Grid container spacing={2}>
            {departments.map((dept, index) => (
              <Grid item xs={12} sm={6} md={4} key={index}>
                <Card elevation={2}>
                  <CardContent>
                    <Typography variant="body1" fontWeight="medium">
                      {dept}
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Box>

        {/* CTA */}
        <Box sx={{ textAlign: 'center', py: 6, mt: 6 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Join Our Community
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Be part of Rangpur Polytechnic Institute's growing digital community
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap', mt: 3 }}>
            <Button variant="contained" size="large" onClick={() => navigate('/downloads')}>
              Download App
            </Button>
            <Button variant="outlined" size="large" onClick={() => navigate('/features')}>
              Learn More
            </Button>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default StatsPage;
