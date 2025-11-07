/**
 * Privacy Policy Page
 * Privacy policy and data handling information
 */

import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Button,
  Paper,
  AppBar,
  Toolbar,
  IconButton,
  Divider,
} from '@mui/material';
import { ArrowBack, School, Security } from '@mui/icons-material';

const PrivacyPage: React.FC = () => {
  const navigate = useNavigate();

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
          <Security sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Privacy Policy
          </Typography>
          <Typography variant="h6" component="h2">
            Your Privacy and Security Matter to Us
          </Typography>
        </Container>
      </Box>

      {/* Content */}
      <Container maxWidth="md" sx={{ py: 6 }}>
        <Paper elevation={2} sx={{ p: 4 }}>
          <Typography variant="body2" color="text.secondary" paragraph>
            Last Updated: November 7, 2025
          </Typography>

          <Typography variant="h5" gutterBottom fontWeight="bold" sx={{ mt: 3 }}>
            1. Introduction
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            Welcome to RPI Echo System. We are committed to protecting your personal information and
            your right to privacy. This Privacy Policy explains how we collect, use, disclose, and
            safeguard your information when you use our mobile application and web dashboard.
          </Typography>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            2. Information We Collect
          </Typography>
          <Typography variant="h6" gutterBottom sx={{ mt: 2, fontSize: '1.1rem' }}>
            2.1 Personal Information
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            We collect personal information that you voluntarily provide to us when you register for
            the application, including:
          </Typography>
          <Box component="ul" sx={{ pl: 3, mb: 2 }}>
            <Typography component="li" variant="body1" paragraph>
              Name, email address, and contact information
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              Student/Employee ID number
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              Role (Student, Teacher, or Administrator)
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              Department and class information
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              Profile picture (optional)
            </Typography>
          </Box>

          <Typography variant="h6" gutterBottom sx={{ mt: 2, fontSize: '1.1rem' }}>
            2.2 Usage Data
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            We automatically collect certain information when you use the application:
          </Typography>
          <Box component="ul" sx={{ pl: 3, mb: 2 }}>
            <Typography component="li" variant="body1" paragraph>
              Device information (device type, operating system)
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              Log data (access times, pages viewed, app features used)
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              Location data (if you grant permission)
            </Typography>
          </Box>

          <Typography variant="h6" gutterBottom sx={{ mt: 2, fontSize: '1.1rem' }}>
            2.3 Communication Data
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            Content of messages, notices, and other communications sent through the platform.
            Messages are encrypted end-to-end and stored securely on our servers.
          </Typography>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            3. How We Use Your Information
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            We use the collected information for various purposes:
          </Typography>
          <Box component="ul" sx={{ pl: 3, mb: 2 }}>
            <Typography component="li" variant="body1" paragraph>
              To provide and maintain our services
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              To facilitate communication between users
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              To send notifications about messages, notices, and updates
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              To monitor and analyze usage patterns and improve our services
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              To detect, prevent, and address technical issues and security threats
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              To comply with legal obligations
            </Typography>
          </Box>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            4. Data Security
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            We implement industry-standard security measures to protect your personal information:
          </Typography>
          <Box component="ul" sx={{ pl: 3, mb: 2 }}>
            <Typography component="li" variant="body1" paragraph>
              <strong>End-to-End Encryption:</strong> All messages are encrypted using AES-256
              encryption
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Secure Authentication:</strong> Support for two-factor authentication and
              biometric login
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Data Encryption:</strong> All data is encrypted in transit (TLS/SSL) and at
              rest
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Regular Security Audits:</strong> We conduct regular security assessments and
              updates
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Access Controls:</strong> Role-based access control ensures users only see
              data they're authorized to access
            </Typography>
          </Box>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            5. Data Sharing and Disclosure
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            We do not sell, trade, or rent your personal information to third parties. We may share
            your information only in the following circumstances:
          </Typography>
          <Box component="ul" sx={{ pl: 3, mb: 2 }}>
            <Typography component="li" variant="body1" paragraph>
              <strong>Within Your Institution:</strong> With other users as necessary for the
              functionality of the platform (e.g., displaying your name in messages)
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Service Providers:</strong> With trusted third-party service providers who
              assist us in operating the platform (e.g., cloud hosting, analytics)
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Legal Requirements:</strong> When required by law or to protect rights,
              property, or safety
            </Typography>
          </Box>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            6. Your Privacy Rights
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            You have the following rights regarding your personal data:
          </Typography>
          <Box component="ul" sx={{ pl: 3, mb: 2 }}>
            <Typography component="li" variant="body1" paragraph>
              <strong>Access:</strong> Request access to your personal data
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Correction:</strong> Request correction of inaccurate data
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Deletion:</strong> Request deletion of your account and data
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Data Portability:</strong> Request a copy of your data in a portable format
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Opt-Out:</strong> Opt-out of non-essential communications
            </Typography>
          </Box>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            7. Data Retention
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            We retain your personal information only for as long as necessary to fulfill the
            purposes outlined in this Privacy Policy, unless a longer retention period is required
            by law. Messages and notices may be retained according to your institution's data
            retention policies.
          </Typography>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            8. Children's Privacy
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            RPI Echo System is intended for use by college students, faculty, and staff. We do not
            knowingly collect personal information from children under 13 years of age. If you
            believe we have collected information from a child under 13, please contact us
            immediately.
          </Typography>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            9. Third-Party Services
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            Our application uses the following third-party services:
          </Typography>
          <Box component="ul" sx={{ pl: 3, mb: 2 }}>
            <Typography component="li" variant="body1" paragraph>
              <strong>Appwrite:</strong> Backend and database services (cloud hosting)
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Sentry:</strong> Error tracking and performance monitoring
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>Google Gemini AI:</strong> AI chatbot functionality
            </Typography>
            <Typography component="li" variant="body1" paragraph>
              <strong>OneSignal:</strong> Push notification services
            </Typography>
          </Box>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            These services have their own privacy policies and we encourage you to review them.
          </Typography>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            10. Changes to This Privacy Policy
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            We may update this Privacy Policy from time to time. We will notify you of any changes
            by posting the new Privacy Policy on this page and updating the "Last Updated" date. We
            encourage you to review this Privacy Policy periodically.
          </Typography>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            11. Contact Us
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            If you have any questions about this Privacy Policy or our data practices, please
            contact:
          </Typography>
          <Box sx={{ pl: 2, mb: 2 }}>
            <Typography variant="body1" paragraph>
            <strong>Developer:</strong> Md Mufthakherul Islam Miraz
            </Typography>
            <Typography variant="body1" paragraph>
              <strong>Website:</strong>{' '}
              <a
                href="https://www.mufthakherul.me"
                target="_blank"
                rel="noopener noreferrer"
                style={{ color: '#1976d2' }}
              >
                www.mufthakherul.me
              </a>
            </Typography>
            <Typography variant="body1" paragraph>
                <strong>Email:</strong>{' '}
                <a
                  href="https://www.mufthakherul.me/contact"
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{ color: '#1976d2' }}
                >
                  Contact through website
                </a>
            </Typography>
          </Box>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h5" gutterBottom fontWeight="bold">
            12. Consent
          </Typography>
          <Typography variant="body1" paragraph sx={{ lineHeight: 1.8 }}>
            By using RPI Echo System, you consent to our Privacy Policy and agree to its terms.
          </Typography>
        </Paper>

        {/* CTA Section */}
        <Box sx={{ textAlign: 'center', py: 4, mt: 4 }}>
          <Typography variant="body1" color="text.secondary" paragraph>
            Have questions about privacy or security?
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap', mt: 3 }}>
            <Button variant="contained" size="large" onClick={() => navigate('/')}>
              Back to Home
            </Button>
              <Button 
                variant="outlined" 
                size="large" 
                onClick={() => window.open('https://www.mufthakherul.me/contact', '_blank')}
              >
                Contact Developer
            </Button>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default PrivacyPage;
