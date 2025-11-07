/**
 * Contact Page
 * Contact form and college information
 */

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  TextField,
  MenuItem,
  Alert,
} from '@mui/material';
import {
  LocationOn,
  Phone,
  Email,
  Language,
  Send,
} from '@mui/icons-material';
import Navigation from '../components/Navigation';

const ContactPage: React.FC = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    role: '',
    subject: '',
    message: '',
  });
  const [submitted, setSubmitted] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    // In production, this would send to backend
  };

  const contactInfo = [
    {
      icon: <LocationOn sx={{ fontSize: 50, color: '#1976d2' }} />,
      title: 'Address',
      detail: 'Dhap, Rangpur',
      detail2: 'Bangladesh',
    },
    {
      icon: <Phone sx={{ fontSize: 50, color: '#4caf50' }} />,
      title: 'Phone',
      detail: '+880-521-63614',
      detail2: 'Sat-Thu: 9 AM - 5 PM',
    },
    {
      icon: <Email sx={{ fontSize: 50, color: '#ff9800' }} />,
      title: 'Email',
      detail: 'info@rangpur.polytech.gov.bd',
      detail2: '',
    },
    {
      icon: <Language sx={{ fontSize: 50, color: '#9c27b0' }} />,
      title: 'Website',
      detail: 'rangpur.polytech.gov.bd',
      detail2: '',
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
          <Email sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            Get in Touch
          </Typography>
          <Typography variant="h6" component="h2">
            Have questions? We'd love to hear from you
          </Typography>
        </Container>
      </Box>

      <Container maxWidth="lg" sx={{ py: 6 }}>
        <Grid container spacing={4}>
          {/* Contact Form */}
          <Grid item xs={12} md={7}>
            <Card elevation={3}>
              <CardContent sx={{ p: 4 }}>
                <Typography variant="h5" fontWeight="bold" gutterBottom>
                  Send us a Message
                </Typography>
                {submitted ? (
                  <Alert severity="success" sx={{ mt: 2 }}>
                    Thank you! Your message has been received. We'll get back to you soon.
                  </Alert>
                ) : (
                  <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
                    <TextField
                      fullWidth
                      label="Your Name"
                      name="name"
                      value={formData.name}
                      onChange={handleChange}
                      required
                      sx={{ mb: 2 }}
                    />
                    <TextField
                      fullWidth
                      label="Email Address"
                      name="email"
                      type="email"
                      value={formData.email}
                      onChange={handleChange}
                      required
                      sx={{ mb: 2 }}
                    />
                    <TextField
                      fullWidth
                      select
                      label="I am a..."
                      name="role"
                      value={formData.role}
                      onChange={handleChange}
                      required
                      sx={{ mb: 2 }}
                    >
                      <MenuItem value="student">Student</MenuItem>
                      <MenuItem value="teacher">Teacher</MenuItem>
                      <MenuItem value="admin">Administrator</MenuItem>
                      <MenuItem value="other">Other</MenuItem>
                    </TextField>
                    <TextField
                      fullWidth
                      label="Subject"
                      name="subject"
                      value={formData.subject}
                      onChange={handleChange}
                      required
                      sx={{ mb: 2 }}
                    />
                    <TextField
                      fullWidth
                      label="Message"
                      name="message"
                      value={formData.message}
                      onChange={handleChange}
                      required
                      multiline
                      rows={4}
                      sx={{ mb: 3 }}
                    />
                    <Button
                      type="submit"
                      variant="contained"
                      size="large"
                      startIcon={<Send />}
                      fullWidth
                    >
                      Send Message
                    </Button>
                  </Box>
                )}
              </CardContent>
            </Card>
          </Grid>

          {/* Contact Info */}
          <Grid item xs={12} md={5}>
            <Grid container spacing={2}>
              {contactInfo.map((info, index) => (
                <Grid item xs={12} key={index}>
                  <Card elevation={2}>
                    <CardContent sx={{ textAlign: 'center' }}>
                      {info.icon}
                      <Typography variant="h6" fontWeight="bold" gutterBottom sx={{ mt: 2 }}>
                        {info.title}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {info.detail}
                      </Typography>
                      {info.detail2 && (
                        <Typography variant="body2" color="text.secondary">
                          {info.detail2}
                        </Typography>
                      )}
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
          </Grid>
        </Grid>

        {/* CTA */}
        <Box sx={{ textAlign: 'center', py: 6, mt: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Ready to Join?
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Download the app and start connecting with your campus
          </Typography>
          <Button variant="contained" size="large" onClick={() => navigate('/downloads')}>
            Download App
          </Button>
        </Box>
      </Container>
    </Box>
  );
};

export default ContactPage;
