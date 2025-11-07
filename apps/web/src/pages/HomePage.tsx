/**
 * Home Landing Page
 * Modern landing page with gradient design and smooth animations
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
  CardActions,
} from '@mui/material';
import {
  School,
  Message,
  Notifications,
  Security,
  Cloud,
  Download,
  Info,
  Policy,
  Code,
  Star,
  LocalFireDepartment,
  People,
} from '@mui/icons-material';
import Navigation from '../components/Navigation';

const HomePage: React.FC = () => {
  const navigate = useNavigate();

  const features = [
    {
      icon: <Message sx={{ fontSize: 48, color: '#6366f1' }} />,
      title: 'Real-time Messaging',
      description: 'Instant communication between students, teachers, and admins with group chat support.',
      gradient: 'linear-gradient(135deg, #667eea0a 0%, #764ba20a 100%)',
    },
    {
      icon: <Notifications sx={{ fontSize: 48, color: '#8b5cf6' }} />,
      title: 'Notice Board',
      description: 'Stay updated with college announcements, events, and important notices.',
      gradient: 'linear-gradient(135deg, #f093fb0a 0%, #f5576c0a 100%)',
    },
    {
      icon: <Security sx={{ fontSize: 48, color: '#06b6d4' }} />,
      title: 'Secure & Private',
      description: 'End-to-end encryption and role-based access control for your data security.',
      gradient: 'linear-gradient(135deg, #4facfe0a 0%, #00f2fe0a 100%)',
    },
    {
      icon: <Cloud sx={{ fontSize: 48, color: '#10b981' }} />,
      title: 'Cloud Sync',
      description: 'Access your data from anywhere with automatic cloud synchronization.',
      gradient: 'linear-gradient(135deg, #43e9700a 0%, #38f9d70a 100%)',
    },
  ];

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      {/* Navigation */}
      <Navigation />

      {/* Hero Section */}
      <Box
        sx={{
          background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #d946ef 100%)',
          color: 'white',
          py: { xs: 8, md: 12 },
          position: 'relative',
          overflow: 'hidden',
          '&::before': {
            content: '""',
            position: 'absolute',
            top: '-50%',
            right: '-10%',
            width: '500px',
            height: '500px',
            borderRadius: '50%',
            background: 'rgba(255, 255, 255, 0.1)',
            blur: '100px',
          },
          '&::after': {
            content: '""',
            position: 'absolute',
            bottom: '-50%',
            left: '-10%',
            width: '400px',
            height: '400px',
            borderRadius: '50%',
            background: 'rgba(255, 255, 255, 0.05)',
            blur: '100px',
          },
        }}
      >
        <Container maxWidth="md" sx={{ position: 'relative', zIndex: 1 }}>
          <Box sx={{ textAlign: 'center', animation: 'fadeInUp 0.8s ease-out' }}>
            <Box
              sx={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 1,
                mb: 2,
                px: 2,
                py: 1,
                borderRadius: 3,
                background: 'rgba(255, 255, 255, 0.1)',
                backdropFilter: 'blur(10px)',
                border: '1px solid rgba(255, 255, 255, 0.2)',
              }}
            >
              <Star sx={{ fontSize: 20 }} />
              <Typography variant="body2" sx={{ fontWeight: 600 }}>
                Next-Gen College Communication
              </Typography>
            </Box>
            
            <Typography 
              variant="h1" 
              component="h1" 
              gutterBottom 
              sx={{
                fontSize: { xs: '2.5rem', sm: '3.5rem', md: '4rem' },
                fontWeight: 800,
                mb: 2,
                letterSpacing: '-0.02em',
              }}
            >
              RPI Echo System
            </Typography>
            
            <Typography 
              variant="h4" 
              component="h2" 
              gutterBottom 
              sx={{
                mb: 3,
                fontWeight: 600,
                fontSize: { xs: '1.25rem', md: '1.5rem' },
                opacity: 0.95,
              }}
            >
              Your Complete College Communication Platform
            </Typography>
            
            <Typography 
              variant="body1" 
              sx={{ 
                mb: 4, 
                fontSize: '1.1rem',
                opacity: 0.9,
                maxWidth: '600px',
                mx: 'auto',
              }}
            >
              Streamline communication between students, teachers, and administrators with our secure, feature-rich platform.
            </Typography>
            
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap' }}>
              <Button
                variant="contained"
                size="large"
                startIcon={<Download />}
                onClick={() => navigate('/downloads')}
                sx={{
                  px: 4,
                  py: 1.5,
                  background: 'linear-gradient(135deg, #ec4899 0%, #f43f5e 100%)',
                  color: '#ffffff',
                  fontWeight: 700,
                  fontSize: '1.05rem',
                  boxShadow: '0 8px 20px rgba(236, 72, 153, 0.4)',
                  transition: 'all 0.3s ease',
                  '&:hover': {
                    transform: 'translateY(-4px)',
                    boxShadow: '0 12px 30px rgba(236, 72, 153, 0.5)',
                  },
                }}
              >
                Download App
              </Button>
              <Button
                variant="outlined"
                size="large"
                onClick={() => navigate('/login')}
                sx={{
                  px: 4,
                  py: 1.5,
                  color: 'white',
                  borderColor: 'rgba(255, 255, 255, 0.5)',
                  borderWidth: '2px',
                  fontWeight: 700,
                  fontSize: '1.05rem',
                  transition: 'all 0.3s ease',
                  '&:hover': {
                    borderColor: 'white',
                    background: 'rgba(255, 255, 255, 0.1)',
                    transform: 'translateY(-4px)',
                  },
                }}
              >
                Web Dashboard
              </Button>
            </Box>
          </Box>
        </Container>
      </Box>

      {/* Features Section */}
      <Container maxWidth="lg" sx={{ py: { xs: 8, md: 12 } }}>
        <Box sx={{ textAlign: 'center', mb: 8 }}>
          <Typography 
            variant="h2" 
            component="h2" 
            gutterBottom 
            sx={{
              fontWeight: 800,
              fontSize: { xs: '2rem', md: '2.5rem' },
              background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              mb: 2,
            }}
          >
            Why Choose RPI Echo System?
          </Typography>
          <Typography 
            variant="body1" 
            color="text.secondary" 
            sx={{ 
              fontSize: '1.1rem',
              maxWidth: '600px',
              mx: 'auto',
            }}
          >
            Everything you need for seamless college communication
          </Typography>
        </Box>
        
        <Grid container spacing={3}>
          {features.map((feature, index) => (
            <Grid item xs={12} sm={6} md={3} key={index}>
              <Card
                sx={{
                  height: '100%',
                  display: 'flex',
                  flexDirection: 'column',
                  textAlign: 'center',
                  background: feature.gradient,
                  border: '1px solid rgba(99, 102, 241, 0.1)',
                  transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                  cursor: 'pointer',
                  '&:hover': {
                    transform: 'translateY(-12px)',
                    boxShadow: '0 20px 40px rgba(99, 102, 241, 0.15)',
                    borderColor: 'rgba(99, 102, 241, 0.3)',
                  },
                }}
              >
                <CardContent sx={{ flexGrow: 1, pt: 4 }}>
                  <Box sx={{ mb: 2, display: 'flex', justifyContent: 'center' }}>
                    {feature.icon}
                  </Box>
                  <Typography variant="h6" component="h3" gutterBottom sx={{ fontWeight: 700 }}>
                    {feature.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {feature.description}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      {/* Stats Section */}
      <Box sx={{ background: 'linear-gradient(135deg, #f8fafc 0%, #e0e7ff 100%)', py: { xs: 8, md: 10 } }}>
        <Container maxWidth="lg">
          <Grid container spacing={4}>
            {[
              { icon: <People />, value: '5000+', label: 'Active Users' },
              { icon: <Message />, value: '50K+', label: 'Messages Sent' },
              { icon: <Notifications />, value: '1000+', label: 'Notices' },
              { icon: <LocalFireDepartment />, value: '99.9%', label: 'Uptime' },
            ].map((stat, index) => (
              <Grid item xs={12} sm={6} md={3} key={index}>
                <Box sx={{ textAlign: 'center' }}>
                  <Box
                    sx={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      width: 60,
                      height: 60,
                      borderRadius: '50%',
                      background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
                      color: 'white',
                      mb: 2,
                      fontSize: 28,
                    }}
                  >
                    {stat.icon}
                  </Box>
                  <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
                    {stat.value}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {stat.label}
                  </Typography>
                </Box>
              </Grid>
            ))}
          </Grid>
        </Container>
      </Box>

      {/* Quick Links Section */}
      <Container maxWidth="lg" sx={{ py: { xs: 8, md: 10 } }}>
        <Typography 
          variant="h2" 
          component="h2" 
          align="center" 
          sx={{
            fontWeight: 800,
            fontSize: { xs: '2rem', md: '2.5rem' },
            mb: 8,
          }}
        >
          Explore More
        </Typography>
        
        <Grid container spacing={3}>
          {[
            { icon: <Info />, title: 'About Project', desc: 'Learn more about RPI Echo System', path: '/about' },
            { icon: <Download />, title: 'Download APKs', desc: 'Get the app for your role', path: '/downloads' },
            { icon: <Policy />, title: 'Privacy & Security', desc: 'Read our privacy policy', path: '/privacy' },
            { icon: <School />, title: 'Features & Guides', desc: 'Discover all features', path: '/features' },
            { icon: <Code />, title: 'About Developer', desc: 'Meet the developer', path: '/developer' },
            { icon: <Notifications />, title: 'Documentation', desc: 'Complete user guide', path: '/documentation' },
          ].map((item, index) => (
            <Grid item xs={12} sm={6} md={4} key={index}>
              <Card
                onClick={() => navigate(item.path)}
                sx={{
                  height: '100%',
                  cursor: 'pointer',
                  transition: 'all 0.3s ease',
                  border: '1px solid rgba(99, 102, 241, 0.1)',
                  '&:hover': {
                    transform: 'translateY(-8px)',
                    boxShadow: '0 15px 35px rgba(99, 102, 241, 0.15)',
                    borderColor: 'rgba(99, 102, 241, 0.3)',
                  },
                }}
              >
                <CardContent>
                  <Box sx={{ fontSize: 40, color: '#6366f1', mb: 2 }}>
                    {item.icon}
                  </Box>
                  <Typography variant="h6" gutterBottom sx={{ fontWeight: 700 }}>
                    {item.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {item.desc}
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button 
                    size="small" 
                    sx={{ color: '#6366f1', fontWeight: 600, ml: 'auto' }}
                  >
                    Learn More →
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      {/* Footer */}
      <Box 
        sx={{ 
          mt: 'auto',
          background: 'linear-gradient(135deg, #1e293b 0%, #0f172a 100%)',
          color: 'white',
          py: 8,
          borderTop: '1px solid rgba(255, 255, 255, 0.1)',
        }}
      >
        <Container maxWidth="lg">
          <Grid container spacing={4} sx={{ mb: 4 }}>
            <Grid item xs={12} md={4}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                <School sx={{ fontSize: 28 }} />
                <Typography variant="h6" sx={{ fontWeight: 700 }}>
                  RPI Echo System
                </Typography>
              </Box>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                Your complete college communication platform. Secure, reliable, and easy to use.
              </Typography>
            </Grid>
            
            <Grid item xs={12} sm={6} md={3}>
              <Typography variant="h6" gutterBottom sx={{ fontWeight: 700, mb: 2 }}>
                Quick Links
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                {['About', 'Features', 'Downloads', 'Support', 'Documentation'].map((link) => (
                  <Button 
                    key={link}
                    color="inherit" 
                    size="small" 
                    sx={{ justifyContent: 'flex-start', opacity: 0.8, '&:hover': { opacity: 1 } }}
                    onClick={() => navigate(`/${link.toLowerCase()}`)}
                  >
                    {link}
                  </Button>
                ))}
              </Box>
            </Grid>
            
            <Grid item xs={12} sm={6} md={3}>
              <Typography variant="h6" gutterBottom sx={{ fontWeight: 700, mb: 2 }}>
                More
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                {['Contact', 'Changelog', 'Stats', 'Privacy Policy', 'Terms of Service', 'Developer'].map((link) => (
                  <Button 
                    key={link}
                    color="inherit" 
                    size="small" 
                    sx={{ justifyContent: 'flex-start', opacity: 0.8, '&:hover': { opacity: 1 } }}
                    onClick={() => navigate(`/${link.toLowerCase().replace(/ /g, '-')}`)}
                  >
                    {link}
                  </Button>
                ))}
              </Box>
            </Grid>
          </Grid>
          
          <Box 
            sx={{ 
              pt: 4, 
              borderTop: '1px solid rgba(255, 255, 255, 0.1)', 
              textAlign: 'center' 
            }}
          >
            <Typography variant="body2" sx={{ opacity: 0.8 }}>
              © 2025 RPI Echo System. All rights reserved. Developed by{' '}
              <a
                href="https://www.mufthakherul.me"
                target="_blank"
                rel="noopener noreferrer"
                style={{ color: '#60a5fa', textDecoration: 'none', fontWeight: 600 }}
              >
                Md Mufthakherul Islam Miraz
              </a>
            </Typography>
          </Box>
        </Container>
      </Box>
    </Box>
  );
};

export default HomePage;
