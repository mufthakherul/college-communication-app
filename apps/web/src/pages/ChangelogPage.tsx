/**
 * Changelog Page
 * Version history for RPI Echo System
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
  Chip,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material';
import {
  Update,
  Star,
} from '@mui/icons-material';
import Navigation from '../components/Navigation';

const ChangelogPage: React.FC = () => {
  const navigate = useNavigate();

  const releases = [
    {
      version: 'v2.1.0',
      date: 'November 2025',
      title: 'Major Update - New Look & Features',
      highlights: [
        'Refreshed design and branding',
        'New help center with detailed guides',
        'Better contact and support options',
        'Performance improvements',
      ],
    },
    {
      version: 'v2.0.0',
      date: 'October 2025',
      title: 'Web Dashboard Launch',
      highlights: [
        'New web dashboard for teachers and admins',
        'Manage student and teacher information',
        'Create and publish notices',
        'View analytics and reports',
      ],
    },
    {
      version: 'v1.8.0',
      date: 'September 2025',
      title: 'AI Features',
      highlights: [
        'AI-powered chatbot for instant help',
        'Smart search across messages and notices',
        'Better performance monitoring',
      ],
    },
    {
      version: 'v1.5.0',
      date: 'August 2025',
      title: 'Security Updates',
      highlights: [
        'Fingerprint and face authentication',
        'Two-factor authentication option',
        'Better data protection',
      ],
    },
    {
      version: 'v1.3.0',
      date: 'July 2025',
      title: 'Productivity Tools',
      highlights: [
        'Assignment tracker with deadlines',
        'Exam countdown timer',
        'QR code tools',
        'Attendance tracking',
      ],
    },
    {
      version: 'v1.0.0',
      date: 'June 2025',
      title: 'Initial Release',
      highlights: [
        'Real-time messaging',
        'Notice board',
        'File sharing',
        'Push notifications',
        'Offline support',
      ],
    },
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
          <Update sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            What's New
          </Typography>
          <Typography variant="h6" component="h2">
            See what we've been working on
          </Typography>
          <Chip
            label="Latest: v2.1.0"
            sx={{ mt: 2, bgcolor: 'white', color: 'primary.main', fontWeight: 'bold' }}
          />
        </Container>
      </Box>

      {/* Releases */}
      <Container maxWidth="lg" sx={{ py: 6 }}>
        {releases.map((release, index) => (
          <Card key={index} elevation={3} sx={{ mb: 4 }}>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Box>
                  <Typography variant="h5" fontWeight="bold" color="primary">
                    {release.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {release.date}
                  </Typography>
                </Box>
                <Chip
                  label={release.version}
                  color={index === 0 ? 'error' : 'default'}
                  sx={{ fontWeight: 'bold' }}
                />
              </Box>
              <List dense>
                {release.highlights.map((highlight, idx) => (
                  <ListItem key={idx}>
                    <ListItemIcon sx={{ minWidth: 32 }}>
                      <Star sx={{ fontSize: 20, color: '#ffc107' }} />
                    </ListItemIcon>
                    <ListItemText primary={highlight} />
                  </ListItem>
                ))}
              </List>
            </CardContent>
          </Card>
        ))}

        {/* CTA */}
        <Box sx={{ textAlign: 'center', py: 6, mt: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Get the Latest Version
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Download now to get all the new features and improvements
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap', mt: 3 }}>
            <Button variant="contained" size="large" onClick={() => navigate('/downloads')}>
              Download Now
            </Button>
            <Button variant="outlined" size="large" onClick={() => navigate('/features')}>
              View Features
            </Button>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default ChangelogPage;
