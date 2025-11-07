/**
 * Terms of Service Page
 * Legal terms and conditions
 */

import React from 'react';
import {
  Box,
  Container,
  Typography,
  Paper,
} from '@mui/material';
import { Gavel } from '@mui/icons-material';
import Navigation from '../components/Navigation';

const TermsPage: React.FC = () => {
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
          <Gavel sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Terms of Service
          </Typography>
          <Typography variant="h6" component="h2">
            Please read these terms carefully before using our services
          </Typography>
        </Container>
      </Box>

      <Container maxWidth="md" sx={{ py: 6 }}>
        <Paper elevation={2} sx={{ p: 4 }}>
          <Typography variant="body2" color="text.secondary" paragraph>
            Last Updated: November 7, 2025
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            1. Acceptance of Terms
          </Typography>
          <Typography variant="body1" paragraph>
            By accessing and using RPI Echo System, you accept and agree to be bound by these
            Terms of Service. If you do not agree to these terms, please do not use our services.
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            2. Eligibility
          </Typography>
          <Typography variant="body1" paragraph>
            This service is exclusively for students, teachers, and staff of Rangpur Polytechnic
            Institute. You must have valid credentials provided by the institution to access the platform.
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            3. User Responsibilities
          </Typography>
          <Typography variant="body1" paragraph>
            You are responsible for:
          </Typography>
          <ul>
            <li><Typography variant="body1">Maintaining the confidentiality of your account credentials</Typography></li>
            <li><Typography variant="body1">All activities that occur under your account</Typography></li>
            <li><Typography variant="body1">Ensuring all information you provide is accurate and current</Typography></li>
            <li><Typography variant="body1">Using the platform in accordance with college policies</Typography></li>
          </ul>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            4. Acceptable Use
          </Typography>
          <Typography variant="body1" paragraph>
            You agree not to:
          </Typography>
          <ul>
            <li><Typography variant="body1">Share inappropriate, offensive, or harmful content</Typography></li>
            <li><Typography variant="body1">Impersonate others or misrepresent your identity</Typography></li>
            <li><Typography variant="body1">Attempt to gain unauthorized access to the system</Typography></li>
            <li><Typography variant="body1">Use the platform for any illegal activities</Typography></li>
            <li><Typography variant="body1">Spam or harass other users</Typography></li>
          </ul>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            5. Privacy
          </Typography>
          <Typography variant="body1" paragraph>
            Your use of RPI Echo System is also governed by our Privacy Policy. Please review it
            to understand how we collect, use, and protect your information.
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            6. Intellectual Property
          </Typography>
          <Typography variant="body1" paragraph>
            All content, features, and functionality of RPI Echo System are owned by Rangpur
            Polytechnic Institute and are protected by copyright and other intellectual property laws.
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            7. Service Availability
          </Typography>
          <Typography variant="body1" paragraph>
            We strive to keep the service available at all times, but we do not guarantee
            uninterrupted access. The service may be temporarily unavailable due to maintenance,
            updates, or technical issues.
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            8. Termination
          </Typography>
          <Typography variant="body1" paragraph>
            We reserve the right to suspend or terminate your access to the platform if you
            violate these terms or engage in behavior that we deem inappropriate or harmful.
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            9. Changes to Terms
          </Typography>
          <Typography variant="body1" paragraph>
            We may update these Terms of Service from time to time. Continued use of the platform
            after changes constitutes acceptance of the updated terms.
          </Typography>

          <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mt: 3 }}>
            10. Contact
          </Typography>
          <Typography variant="body1" paragraph>
            If you have questions about these Terms of Service, please contact us at
            info@rangpur.polytech.gov.bd
          </Typography>
        </Paper>
      </Container>
    </Box>
  );
};

export default TermsPage;
