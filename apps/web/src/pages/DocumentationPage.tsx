/**
 * Documentation Page
 * Guides and resources for using RPI Echo System
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
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material';
import {
  MenuBook,
  Description,
  CheckCircle,
} from '@mui/icons-material';
import Navigation from '../components/Navigation';

const DocumentationPage: React.FC = () => {
  const navigate = useNavigate();

  const guides = [
    {
      icon: <MenuBook sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Getting Started',
      description: 'Everything you need to know to start using the platform',
      topics: [
        'Creating your account',
        'First time login',
        'Setting up your profile',
        'Understanding the interface',
      ],
    },
    {
      icon: <Description sx={{ fontSize: 50, color: '#4caf50' }} />,
      title: 'Features Guide',
      description: 'Learn how to use all the features effectively',
      topics: [
        'Sending and receiving messages',
        'Reading notices and announcements',
        'Managing your calendar',
        'Using the assignment tracker',
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
          <MenuBook sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Documentation
          </Typography>
          <Typography variant="h6" component="h2">
            Guides and resources to help you get the most out of the platform
          </Typography>
        </Container>
      </Box>

      {/* Guides */}
      <Container maxWidth="lg" sx={{ py: 6 }}>
        <Grid container spacing={4}>
          {guides.map((guide, index) => (
            <Grid item xs={12} md={6} key={index}>
              <Card elevation={2} sx={{ height: '100%' }}>
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    {guide.icon}
                    <Typography variant="h5" fontWeight="bold" sx={{ ml: 2 }}>
                      {guide.title}
                    </Typography>
                  </Box>
                  <Typography variant="body2" color="text.secondary" paragraph>
                    {guide.description}
                  </Typography>
                  <List dense>
                    {guide.topics.map((topic, idx) => (
                      <ListItem key={idx}>
                        <ListItemIcon sx={{ minWidth: 32 }}>
                          <CheckCircle sx={{ fontSize: 20, color: '#4caf50' }} />
                        </ListItemIcon>
                        <ListItemText primary={topic} />
                      </ListItem>
                    ))}
                  </List>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* Quick Links */}
        <Box sx={{ mt: 6 }}>
          <Typography variant="h5" fontWeight="bold" gutterBottom>
            Need More Help?
          </Typography>
          <Grid container spacing={3} sx={{ mt: 1 }}>
            <Grid item xs={12} sm={6} md={4}>
              <Card elevation={2}>
                <CardContent>
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    Video Tutorials
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Watch step-by-step video guides
                  </Typography>
                  <Button sx={{ mt: 2 }} variant="outlined">
                    Coming Soon
                  </Button>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Card elevation={2}>
                <CardContent>
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    FAQ
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Find answers to common questions
                  </Typography>
                  <Button sx={{ mt: 2 }} variant="outlined" onClick={() => navigate('/support')}>
                    View FAQ
                  </Button>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Card elevation={2}>
                <CardContent>
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    Contact Support
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Get in touch with our support team
                  </Typography>
                  <Button sx={{ mt: 2 }} variant="outlined" onClick={() => navigate('/contact')}>
                    Contact Us
                  </Button>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Box>

        {/* CTA */}
        <Box sx={{ textAlign: 'center', py: 6, mt: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Ready to Get Started?
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Download the app and start connecting with your campus community
          </Typography>
          <Button variant="contained" size="large" onClick={() => navigate('/downloads')}>
            Download Now
          </Button>
        </Box>
      </Container>
    </Box>
  );
};

export default DocumentationPage;
