/**
 * Home Landing Page
 * Main landing page with navigation to all sections
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
  AppBar,
  Toolbar,
  IconButton,
  Menu,
  MenuItem,
} from '@mui/material';
import {
  Menu as MenuIcon,
  School,
  Message,
  Notifications,
  Security,
  Cloud,
  Download,
  Info,
  Policy,
  Code,
} from '@mui/icons-material';

const HomePage: React.FC = () => {
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleNavigate = (path: string) => {
    navigate(path);
    handleClose();
  };

  const features = [
    {
      icon: <Message sx={{ fontSize: 40, color: '#1976d2' }} />,
      title: 'Real-time Messaging',
      description: 'Instant communication between students, teachers, and admins with group chat support.',
    },
    {
      icon: <Notifications sx={{ fontSize: 40, color: '#1976d2' }} />,
      title: 'Notice Board',
      description: 'Stay updated with college announcements, events, and important notices.',
    },
    {
      icon: <Security sx={{ fontSize: 40, color: '#1976d2' }} />,
      title: 'Secure & Private',
      description: 'End-to-end encryption and role-based access control for your data security.',
    },
    {
      icon: <Cloud sx={{ fontSize: 40, color: '#1976d2' }} />,
      title: 'Cloud Sync',
      description: 'Access your data from anywhere with automatic cloud synchronization.',
    },
  ];

  return (
    <Box sx={{ flexGrow: 1 }}>
      {/* Navigation Bar */}
      <AppBar position="static" elevation={2}>
        <Toolbar>
          <School sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            RPI Echo System
          </Typography>
          <Box sx={{ display: { xs: 'none', md: 'flex' }, gap: 2 }}>
            <Button color="inherit" onClick={() => navigate('/')}>
              Home
            </Button>
            <Button color="inherit" onClick={() => navigate('/about')}>
              About
            </Button>
            <Button color="inherit" onClick={() => navigate('/features')}>
              Features
            </Button>
            <Button color="inherit" onClick={() => navigate('/downloads')}>
              Downloads
            </Button>
            <Button color="inherit" onClick={() => navigate('/support')}>
              Support
            </Button>
            <Button color="inherit" onClick={() => navigate('/documentation')}>
              Docs
            </Button>
            <Button color="inherit" onClick={() => navigate('/contact')}>
              Contact
            </Button>
            <Button color="inherit" onClick={() => navigate('/stats')}>
              Stats
            </Button>
            <Button
              variant="contained"
              color="secondary"
              onClick={() => navigate('/login')}
              sx={{ ml: 2 }}
            >
              Login
            </Button>
          </Box>
          <Box sx={{ display: { xs: 'flex', md: 'none' } }}>
            <IconButton
              size="large"
              aria-label="menu"
              aria-controls="menu-appbar"
              aria-haspopup="true"
              onClick={handleMenu}
              color="inherit"
            >
              <MenuIcon />
            </IconButton>
            <Menu
              id="menu-appbar"
              anchorEl={anchorEl}
              anchorOrigin={{
                vertical: 'top',
                horizontal: 'right',
              }}
              keepMounted
              transformOrigin={{
                vertical: 'top',
                horizontal: 'right',
              }}
              open={Boolean(anchorEl)}
              onClose={handleClose}
            >
              <MenuItem onClick={() => handleNavigate('/')}>Home</MenuItem>
              <MenuItem onClick={() => handleNavigate('/about')}>About</MenuItem>
              <MenuItem onClick={() => handleNavigate('/features')}>Features</MenuItem>
              <MenuItem onClick={() => handleNavigate('/downloads')}>Downloads</MenuItem>
              <MenuItem onClick={() => handleNavigate('/support')}>Support</MenuItem>
              <MenuItem onClick={() => handleNavigate('/documentation')}>Documentation</MenuItem>
              <MenuItem onClick={() => handleNavigate('/contact')}>Contact</MenuItem>
              <MenuItem onClick={() => handleNavigate('/changelog')}>Changelog</MenuItem>
              <MenuItem onClick={() => handleNavigate('/stats')}>Stats</MenuItem>
              <MenuItem onClick={() => handleNavigate('/privacy')}>Privacy</MenuItem>
              <MenuItem onClick={() => handleNavigate('/developer')}>Developer</MenuItem>
              <MenuItem onClick={() => handleNavigate('/login')}>Login</MenuItem>
            </Menu>
          </Box>
        </Toolbar>
      </AppBar>

      {/* Hero Section */}
      <Box
        sx={{
          bgcolor: 'primary.main',
          color: 'white',
          py: 10,
          textAlign: 'center',
        }}
      >
        <Container maxWidth="md">
          <School sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h2" component="h1" gutterBottom fontWeight="bold">
            RPI Echo System
          </Typography>
          <Typography variant="h5" component="h2" gutterBottom sx={{ mb: 4 }}>
            Your Complete College Communication Platform
          </Typography>
          <Typography variant="body1" sx={{ mb: 4, fontSize: '1.2rem' }}>
            Streamline communication between students, teachers, and administrators
            with our secure, feature-rich mobile application.
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap' }}>
            <Button
              variant="contained"
              size="large"
              color="secondary"
              startIcon={<Download />}
              onClick={() => navigate('/downloads')}
              sx={{ px: 4, py: 1.5 }}
            >
              Download App
            </Button>
            <Button
              variant="outlined"
              size="large"
              sx={{ color: 'white', borderColor: 'white', px: 4, py: 1.5 }}
              onClick={() => navigate('/login')}
            >
              Web Dashboard
            </Button>
          </Box>
        </Container>
      </Box>

      {/* Features Section */}
      <Container maxWidth="lg" sx={{ py: 8 }}>
        <Typography variant="h3" component="h2" align="center" gutterBottom fontWeight="bold">
          Why Choose RPI Echo System?
        </Typography>
        <Typography variant="body1" align="center" color="text.secondary" sx={{ mb: 6 }}>
          Everything you need for easy college communication in one app
        </Typography>
        <Grid container spacing={4}>
          {features.map((feature, index) => (
            <Grid item xs={12} sm={6} md={3} key={index}>
              <Card
                sx={{
                  height: '100%',
                  display: 'flex',
                  flexDirection: 'column',
                  textAlign: 'center',
                  transition: 'transform 0.2s',
                  '&:hover': {
                    transform: 'translateY(-8px)',
                    boxShadow: 4,
                  },
                }}
              >
                <CardContent sx={{ flexGrow: 1, pt: 4 }}>
                  <Box sx={{ mb: 2 }}>{feature.icon}</Box>
                  <Typography variant="h6" component="h3" gutterBottom fontWeight="bold">
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

      {/* Quick Links Section */}
      <Box sx={{ bgcolor: 'grey.100', py: 8 }}>
        <Container maxWidth="lg">
          <Typography variant="h3" component="h2" align="center" gutterBottom fontWeight="bold">
            Explore More
          </Typography>
          <Grid container spacing={3} sx={{ mt: 2 }}>
            <Grid item xs={12} sm={6} md={4}>
              <Card>
                <CardContent>
                  <Info sx={{ fontSize: 40, color: '#1976d2', mb: 2 }} />
                  <Typography variant="h6" gutterBottom>
                    About Project
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Learn more about RPI Echo System and how it can transform college communication.
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => navigate('/about')}>
                    Learn More
                  </Button>
                </CardActions>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Card>
                <CardContent>
                  <Download sx={{ fontSize: 40, color: '#1976d2', mb: 2 }} />
                  <Typography variant="h6" gutterBottom>
                    Download APKs
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Get the app for Students, Teachers, or Admins. Available for Android.
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => navigate('/downloads')}>
                    Download Now
                  </Button>
                </CardActions>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Card>
                <CardContent>
                  <Policy sx={{ fontSize: 40, color: '#1976d2', mb: 2 }} />
                  <Typography variant="h6" gutterBottom>
                    Privacy & Security
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Your privacy matters. Read our privacy policy and security measures.
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => navigate('/privacy')}>
                    Read Policy
                  </Button>
                </CardActions>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Card>
                <CardContent>
                  <School sx={{ fontSize: 40, color: '#1976d2', mb: 2 }} />
                  <Typography variant="h6" gutterBottom>
                    Features & Guides
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Discover all features and learn how to use the app effectively.
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => navigate('/features')}>
                    View Features
                  </Button>
                </CardActions>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={4}>
              <Card>
                <CardContent>
                  <Code sx={{ fontSize: 40, color: '#1976d2', mb: 2 }} />
                  <Typography variant="h6" gutterBottom>
                    About Developer
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Meet the developer behind RPI Echo System and explore more projects.
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => navigate('/developer')}>
                    Meet Developer
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          </Grid>
        </Container>
      </Box>

      {/* Footer */}
      <Box sx={{ bgcolor: 'primary.dark', color: 'white', py: 4, mt: 'auto' }}>
        <Container maxWidth="lg">
          <Grid container spacing={4}>
            <Grid item xs={12} md={6}>
              <Typography variant="h6" gutterBottom>
                RPI Echo System
              </Typography>
              <Typography variant="body2">
                Your complete college communication platform. Secure, reliable, and easy to use.
              </Typography>
            </Grid>
            <Grid item xs={12} md={3}>
              <Typography variant="h6" gutterBottom>
                Quick Links
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/about')}>
                  About
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/features')}>
                  Features
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/downloads')}>
                  Downloads
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/support')}>
                  Support
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/documentation')}>
                  Documentation
                </Button>
              </Box>
            </Grid>
            <Grid item xs={12} md={3}>
              <Typography variant="h6" gutterBottom>
                More
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/contact')}>
                  Contact
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/changelog')}>
                  Changelog
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/stats')}>
                  Stats
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/privacy')}>
                  Privacy Policy
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/terms')}>
                  Terms of Service
                </Button>
                <Button color="inherit" size="small" sx={{ justifyContent: 'flex-start' }} onClick={() => navigate('/developer')}>
                  Developer
                </Button>
              </Box>
            </Grid>
          </Grid>
          <Box sx={{ mt: 4, pt: 3, borderTop: '1px solid rgba(255,255,255,0.1)', textAlign: 'center' }}>
            <Typography variant="body2">
              © 2025 RPI Echo System. All rights reserved. Developed by{' '}
              <a
                href="https://www.mufthakherul.me"
                target="_blank"
                rel="noopener noreferrer"
                style={{ color: 'white', textDecoration: 'underline' }}
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
