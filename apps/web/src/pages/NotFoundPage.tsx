/**
 * 404 Not Found Page
 * Displayed when user navigates to invalid route
 */

import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Button,
} from '@mui/material';
import { SearchOff, Home, ArrowBack } from '@mui/icons-material';
import Navigation from '../components/Navigation';

const NotFoundPage: React.FC = () => {
  const navigate = useNavigate();

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: 'grey.50' }}>
      <Navigation />

      <Container maxWidth="md" sx={{ py: 10, textAlign: 'center' }}>
        <SearchOff sx={{ fontSize: 120, color: 'text.secondary', mb: 3 }} />
        <Typography variant="h1" component="h1" fontWeight="bold" color="primary" gutterBottom>
          404
        </Typography>
        <Typography variant="h4" component="h2" gutterBottom fontWeight="medium">
          Page Not Found
        </Typography>
        <Typography variant="body1" color="text.secondary" paragraph sx={{ mt: 2, mb: 4 }}>
          Sorry, the page you're looking for doesn't exist or has been moved.
        </Typography>
        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap' }}>
          <Button
            variant="contained"
            size="large"
            startIcon={<Home />}
            onClick={() => navigate('/')}
          >
            Go Home
          </Button>
          <Button
            variant="outlined"
            size="large"
            startIcon={<ArrowBack />}
            onClick={() => navigate(-1)}
          >
            Go Back
          </Button>
        </Box>
      </Container>
    </Box>
  );
};

export default NotFoundPage;
