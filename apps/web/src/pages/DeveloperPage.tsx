/**
 * Developer Page
 * Information about the developer
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
  Paper,
  AppBar,
  Toolbar,
  IconButton,
  Avatar,
  Chip,
  Link as MuiLink,
} from '@mui/material';
import {
  ArrowBack,
  School,
  Code,
  Language,
  GitHub,
  LinkedIn,
  Email,
  Work,
  EmojiObjects,
} from '@mui/icons-material';

const DeveloperPage: React.FC = () => {
  const navigate = useNavigate();

  const skills = [
    'Flutter & Dart',
    'React & TypeScript',
    'Node.js',
    'Python',
    'Mobile App Development',
    'Web Development',
    'UI/UX Design',
    'Backend Development',
    'Cloud Services',
    'Database Design',
  ];

  const projects = [
    {
      name: 'Campus Mesh',
      description: 'Complete college communication platform with mobile and web dashboards',
      tech: ['Flutter', 'React', 'TypeScript', 'Appwrite'],
    },
    {
      name: 'Portfolio Website',
      description: 'Personal portfolio showcasing projects and skills',
      tech: ['React', 'Next.js', 'TailwindCSS'],
    },
  ];

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
            Campus Mesh
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
          <Code sx={{ fontSize: 80, mb: 2 }} />
          <Typography variant="h3" component="h1" gutterBottom fontWeight="bold">
            About the Developer
          </Typography>
          <Typography variant="h6" component="h2">
            Meet the Mind Behind Campus Mesh
          </Typography>
        </Container>
      </Box>

      {/* Main Content */}
      <Container maxWidth="lg" sx={{ py: 6 }}>
        {/* Developer Info */}
        <Paper elevation={2} sx={{ p: 4, mb: 4 }}>
          <Grid container spacing={4} alignItems="center">
            <Grid item xs={12} md={4} sx={{ textAlign: 'center' }}>
              <Avatar
                sx={{
                  width: 200,
                  height: 200,
                  margin: '0 auto',
                  bgcolor: 'primary.main',
                  fontSize: 80,
                }}
              >
                MH
              </Avatar>
              <Typography variant="h4" sx={{ mt: 2 }} fontWeight="bold">
                Mufthak Herul
              </Typography>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                Full Stack Developer
              </Typography>
              <Box sx={{ mt: 2, display: 'flex', gap: 1, justifyContent: 'center' }}>
                <IconButton
                  color="primary"
                  onClick={() => window.open('https://www.mufthakherul.me', '_blank')}
                >
                  <Language />
                </IconButton>
                <IconButton
                  color="primary"
                  onClick={() => window.open('https://github.com/mufthakherul', '_blank')}
                >
                  <GitHub />
                </IconButton>
                <IconButton
                  color="primary"
                  onClick={() => window.open('https://linkedin.com/in/mufthakherul', '_blank')}
                >
                  <LinkedIn />
                </IconButton>
              </Box>
            </Grid>
            <Grid item xs={12} md={8}>
              <Typography variant="h5" gutterBottom fontWeight="bold" color="primary">
                Hello! 👋
              </Typography>
              <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
                I'm Mufthak Herul, a passionate full-stack developer with expertise in building
                mobile and web applications. I created Campus Mesh to solve real communication
                challenges in educational institutions and make college life more connected and
                organized.
              </Typography>
              <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
                With experience in modern technologies like Flutter, React, and cloud services, I
                focus on creating user-friendly, secure, and scalable applications that make a
                difference.
              </Typography>
              <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
                When I'm not coding, I enjoy learning new technologies, contributing to open-source
                projects, and exploring innovative solutions to everyday problems.
              </Typography>
            </Grid>
          </Grid>
        </Paper>

        {/* Skills */}
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom fontWeight="bold" color="primary">
            Skills & Technologies
          </Typography>
          <Paper elevation={2} sx={{ p: 3, mt: 2 }}>
            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
              {skills.map((skill, index) => (
                <Chip
                  key={index}
                  label={skill}
                  color="primary"
                  variant="outlined"
                  sx={{ fontSize: '0.95rem', py: 2.5 }}
                />
              ))}
            </Box>
          </Paper>
        </Box>

        {/* Featured Projects */}
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom fontWeight="bold" color="primary">
            Featured Projects
          </Typography>
          <Grid container spacing={3} sx={{ mt: 1 }}>
            {projects.map((project, index) => (
              <Grid item xs={12} md={6} key={index}>
                <Card
                  elevation={2}
                  sx={{
                    height: '100%',
                    transition: 'transform 0.2s, box-shadow 0.2s',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: 4,
                    },
                  }}
                >
                  <CardContent sx={{ p: 3 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                      <Work sx={{ fontSize: 40, color: '#1976d2', mr: 2 }} />
                      <Typography variant="h5" fontWeight="bold">
                        {project.name}
                      </Typography>
                    </Box>
                    <Typography variant="body1" color="text.secondary" paragraph>
                      {project.description}
                    </Typography>
                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                      {project.tech.map((tech, idx) => (
                        <Chip key={idx} label={tech} size="small" color="secondary" />
                      ))}
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Box>

        {/* Why Campus Mesh */}
        <Paper elevation={2} sx={{ p: 4, mb: 4, bgcolor: '#e3f2fd' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
            <EmojiObjects sx={{ fontSize: 50, color: '#1976d2', mr: 2 }} />
            <Typography variant="h4" fontWeight="bold" color="primary">
              Why I Built Campus Mesh
            </Typography>
          </Box>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            During my college years, I noticed the challenges students and faculty faced with
            fragmented communication channels - from WhatsApp groups to email threads and physical
            notice boards. Important announcements were often missed, and coordinating activities
            was unnecessarily complicated.
          </Typography>
          <Typography variant="body1" paragraph sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            Campus Mesh was born from the vision of creating a unified platform that brings together
            all college communication needs - from instant messaging and announcements to assignment
            tracking and administrative tools. The goal was to make college communication seamless,
            secure, and accessible to everyone.
          </Typography>
          <Typography variant="body1" sx={{ fontSize: '1.1rem', lineHeight: 1.8 }}>
            This project combines my passion for technology with the desire to solve real-world
            problems and make a positive impact on the educational community.
          </Typography>
        </Paper>

        {/* Contact Section */}
        <Box sx={{ mb: 4 }}>
          <Typography variant="h4" gutterBottom fontWeight="bold" color="primary">
            Get in Touch
          </Typography>
          <Paper elevation={2} sx={{ p: 4, mt: 2 }}>
            <Grid container spacing={3}>
              <Grid item xs={12} md={4}>
                <Box sx={{ textAlign: 'center' }}>
                  <Language sx={{ fontSize: 50, color: '#1976d2', mb: 1 }} />
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    Website
                  </Typography>
                  <MuiLink
                    href="https://www.mufthakherul.me"
                    target="_blank"
                    rel="noopener noreferrer"
                    sx={{ fontSize: '1rem' }}
                  >
                    www.mufthakherul.me
                  </MuiLink>
                </Box>
              </Grid>
              <Grid item xs={12} md={4}>
                <Box sx={{ textAlign: 'center' }}>
                  <GitHub sx={{ fontSize: 50, color: '#1976d2', mb: 1 }} />
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    GitHub
                  </Typography>
                  <MuiLink
                    href="https://github.com/mufthakherul"
                    target="_blank"
                    rel="noopener noreferrer"
                    sx={{ fontSize: '1rem' }}
                  >
                    @mufthakherul
                  </MuiLink>
                </Box>
              </Grid>
              <Grid item xs={12} md={4}>
                <Box sx={{ textAlign: 'center' }}>
                  <LinkedIn sx={{ fontSize: 50, color: '#1976d2', mb: 1 }} />
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    LinkedIn
                  </Typography>
                  <MuiLink
                    href="https://linkedin.com/in/mufthakherul"
                    target="_blank"
                    rel="noopener noreferrer"
                    sx={{ fontSize: '1rem' }}
                  >
                    Mufthak Herul
                  </MuiLink>
                </Box>
              </Grid>
            </Grid>
            <Box sx={{ textAlign: 'center', mt: 4 }}>
              <Typography variant="body1" color="text.secondary" paragraph>
                Interested in collaboration or have questions about Campus Mesh?
              </Typography>
              <Button
                variant="contained"
                size="large"
                startIcon={<Email />}
                onClick={() => window.open('https://www.mufthakherul.me', '_blank')}
              >
                Contact Me
              </Button>
            </Box>
          </Paper>
        </Box>

        {/* CTA Section */}
        <Box sx={{ textAlign: 'center', py: 4 }}>
          <Typography variant="h5" gutterBottom fontWeight="bold">
            Explore Campus Mesh
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Try Campus Mesh and experience the future of college communication
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap', mt: 3 }}>
            <Button
              variant="contained"
              size="large"
              onClick={() => navigate('/downloads')}
            >
              Download App
            </Button>
            <Button variant="outlined" size="large" onClick={() => navigate('/')}>
              Back to Home
            </Button>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default DeveloperPage;
