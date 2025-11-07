/**
 * Support & Help Page
 * FAQ and support resources
 */

import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Button,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Card,
  CardContent,
  Grid,
} from '@mui/material';
import {
  ExpandMore,
  Help,
  Phone,
  Email,
  LocationOn,
} from '@mui/icons-material';
import Navigation from '../components/Navigation';

const SupportPage: React.FC = () => {
  const navigate = useNavigate();

  const faqs = [
    {
      category: 'Getting Started',
      questions: [
        {
          q: 'How do I download the app?',
          a: 'Visit the Downloads page and select your role (Student/Teacher/Admin). Download the app for your device and install it following the on-screen instructions.',
        },
        {
          q: 'What are my login credentials?',
          a: 'Your login credentials are provided by the college administration. If you haven\'t received them, please contact your department office.',
        },
        {
          q: 'Is the app free?',
          a: 'Yes, the app is completely free for all students, teachers, and staff of Rangpur Polytechnic Institute.',
        },
      ],
    },
    {
      category: 'Account & Usage',
      questions: [
        {
          q: 'I forgot my password. What should I do?',
          a: 'Use the "Forgot Password" link on the login page or contact your IT department for assistance.',
        },
        {
          q: 'Can I use the app on multiple devices?',
          a: 'Yes, you can log in on multiple devices with the same account.',
        },
        {
          q: 'How do I update my profile information?',
          a: 'Go to Settings > Profile and update your information there.',
        },
      ],
    },
    {
      category: 'Privacy & Security',
      questions: [
        {
          q: 'Is my data secure?',
          a: 'Yes, we take security seriously. All data is encrypted and stored securely. Read our Privacy Policy for more details.',
        },
        {
          q: 'Who can see my information?',
          a: 'Only authorized users within your college can see your profile information. We never share your data with third parties.',
        },
      ],
    },
    {
      category: 'Troubleshooting',
      questions: [
        {
          q: 'The app won\'t open or keeps crashing',
          a: 'Try clearing the app cache, restarting your device, or reinstalling the app. If the problem persists, contact support.',
        },
        {
          q: 'I\'m not receiving notifications',
          a: 'Check that notifications are enabled in your device settings and within the app settings.',
        },
        {
          q: 'Messages aren\'t sending',
          a: 'Check your internet connection. If you\'re connected but messages still won\'t send, try restarting the app.',
        },
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
          <Help sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Help & Support
          </Typography>
          <Typography variant="h6" component="h2">
            Find answers to common questions or get in touch with us
          </Typography>
        </Container>
      </Box>

      {/* FAQ Section */}
      <Container maxWidth="lg" sx={{ py: 6 }}>
        <Typography variant="h4" fontWeight="bold" gutterBottom sx={{ mb: 4 }}>
          Frequently Asked Questions
        </Typography>

        {faqs.map((category, catIndex) => (
          <Box key={catIndex} sx={{ mb: 4 }}>
            <Typography variant="h5" fontWeight="bold" gutterBottom sx={{ mb: 2, color: 'primary.main' }}>
              {category.category}
            </Typography>
            {category.questions.map((faq, faqIndex) => (
              <Accordion key={faqIndex} elevation={2}>
                <AccordionSummary expandIcon={<ExpandMore />}>
                  <Typography fontWeight="medium">{faq.q}</Typography>
                </AccordionSummary>
                <AccordionDetails>
                  <Typography color="text.secondary">{faq.a}</Typography>
                </AccordionDetails>
              </Accordion>
            ))}
          </Box>
        ))}

        {/* Contact Support */}
        <Box sx={{ mt: 6 }}>
          <Typography variant="h4" fontWeight="bold" gutterBottom sx={{ mb: 3 }}>
            Still Need Help?
          </Typography>
          <Grid container spacing={3}>
            <Grid item xs={12} md={4}>
              <Card elevation={2}>
                <CardContent sx={{ textAlign: 'center' }}>
                  <Email sx={{ fontSize: 50, color: '#1976d2', mb: 2 }} />
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    Email
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    support@rangpur.polytech.gov.bd
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} md={4}>
              <Card elevation={2}>
                <CardContent sx={{ textAlign: 'center' }}>
                  <Phone sx={{ fontSize: 50, color: '#4caf50', mb: 2 }} />
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    Phone
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    +880-521-63614
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} md={4}>
              <Card elevation={2}>
                <CardContent sx={{ textAlign: 'center' }}>
                  <LocationOn sx={{ fontSize: 50, color: '#ff9800', mb: 2 }} />
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    Visit Us
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    IT Office, Main Campus
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Sat-Thu: 9 AM - 5 PM
                  </Typography>
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
            Download the app and join your campus community
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap', mt: 3 }}>
            <Button variant="contained" size="large" onClick={() => navigate('/downloads')}>
              Download App
            </Button>
            <Button variant="outlined" size="large" onClick={() => navigate('/contact')}>
              Contact Us
            </Button>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default SupportPage;
