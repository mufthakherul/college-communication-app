/**
 * Shared Navigation Component
 * Used across all public pages
 */

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  IconButton,
  Box,
  Menu,
  MenuItem,
} from '@mui/material';
import { School, Menu as MenuIcon } from '@mui/icons-material';

interface NavigationProps {
  showBackButton?: boolean;
}

const Navigation: React.FC<NavigationProps> = () => {
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);

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

  return (
    <AppBar 
      position="sticky" 
      elevation={0}
      sx={{
        background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
        backdropFilter: 'blur(10px)',
        borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
        boxShadow: '0 4px 30px rgba(0, 0, 0, 0.1)',
      }}
    >
      <Toolbar sx={{ py: 1 }}>
        <Box 
          sx={{ 
            display: 'flex',
            alignItems: 'center',
            gap: 1,
            cursor: 'pointer',
            transition: 'transform 0.3s ease',
            '&:hover': {
              transform: 'scale(1.05)',
            },
          }}
          onClick={() => navigate('/')}
        >
          <School sx={{ fontSize: 32 }} />
          <Typography
            variant="h5"
            component="div"
            sx={{ 
              fontWeight: 700,
              letterSpacing: '-0.5px',
              background: 'linear-gradient(135deg, #ffffff 0%, #e0e7ff 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}
          >
            RPI Echo
          </Typography>
        </Box>
        
        {/* Desktop Navigation */}
        <Box sx={{ display: { xs: 'none', md: 'flex' }, gap: 0.5, ml: 4, flexGrow: 1 }}>
          {['Home', 'About', 'Features', 'Download', 'Help', 'Contact'].map((item) => (
            <Button 
              key={item}
              color="inherit" 
              onClick={() => handleNavigate(item === 'Home' ? '/' : `/${item.toLowerCase()}`)}
              sx={{
                fontSize: '0.9rem',
                fontWeight: 500,
                position: 'relative',
                transition: 'color 0.3s ease',
                '&::after': {
                  content: '""',
                  position: 'absolute',
                  bottom: 8,
                  left: 0,
                  width: '0%',
                  height: '2px',
                  background: '#ffffff',
                  transition: 'width 0.3s ease',
                },
                '&:hover::after': {
                  width: '100%',
                },
              }}
            >
              {item}
            </Button>
          ))}
        </Box>

        <Button
          variant="contained"
          onClick={() => navigate('/login')}
          sx={{
            ml: { xs: 'auto', md: 2 },
            display: { xs: 'none', sm: 'flex' },
            background: 'linear-gradient(135deg, #ec4899 0%, #f43f5e 100%)',
            color: '#ffffff',
            fontWeight: 600,
            px: 3,
            py: 1,
            borderRadius: 2,
            boxShadow: '0 4px 15px rgba(236, 72, 153, 0.3)',
            transition: 'all 0.3s ease',
            '&:hover': {
              transform: 'translateY(-2px)',
              boxShadow: '0 8px 25px rgba(236, 72, 153, 0.4)',
            },
          }}
        >
          Sign In
        </Button>

        {/* Mobile Navigation */}
        <Box sx={{ display: { xs: 'flex', md: 'none' }, ml: 'auto' }}>
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
            sx={{
              '& .MuiPaper-root': {
                background: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',
                backdropFilter: 'blur(10px)',
                border: '1px solid rgba(99, 102, 241, 0.1)',
                boxShadow: '0 10px 30px rgba(0, 0, 0, 0.1)',
              },
            }}
          >
            <MenuItem onClick={() => handleNavigate('/')}>Home</MenuItem>
            <MenuItem onClick={() => handleNavigate('/about')}>About</MenuItem>
            <MenuItem onClick={() => handleNavigate('/features')}>Features</MenuItem>
            <MenuItem onClick={() => handleNavigate('/download')}>Download</MenuItem>
            <MenuItem onClick={() => handleNavigate('/help')}>Help</MenuItem>
            <MenuItem onClick={() => handleNavigate('/contact')}>Contact</MenuItem>
            <MenuItem onClick={() => handleNavigate('/stats')}>Stats</MenuItem>
            <MenuItem onClick={() => handleNavigate('/privacy')}>Privacy</MenuItem>
            <MenuItem onClick={() => handleNavigate('/login')}>Sign In</MenuItem>
          </Menu>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Navigation;
