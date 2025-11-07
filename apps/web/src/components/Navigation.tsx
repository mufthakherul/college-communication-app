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
    <AppBar position="static" elevation={2}>
      <Toolbar>
        <School sx={{ mr: 2, cursor: 'pointer' }} onClick={() => navigate('/')} />
        <Typography
          variant="h6"
          component="div"
          sx={{ flexGrow: 1, cursor: 'pointer' }}
          onClick={() => navigate('/')}
        >
          RPI Echo System
        </Typography>
        
        {/* Desktop Navigation */}
        <Box sx={{ display: { xs: 'none', md: 'flex' }, gap: 1.5 }}>
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
            Download
          </Button>
          <Button color="inherit" onClick={() => navigate('/support')}>
            Help
          </Button>
          <Button color="inherit" onClick={() => navigate('/contact')}>
            Contact
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

        {/* Mobile Navigation */}
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
            <MenuItem onClick={() => handleNavigate('/downloads')}>Download</MenuItem>
            <MenuItem onClick={() => handleNavigate('/support')}>Help</MenuItem>
            <MenuItem onClick={() => handleNavigate('/contact')}>Contact</MenuItem>
            <MenuItem onClick={() => handleNavigate('/stats')}>Stats</MenuItem>
            <MenuItem onClick={() => handleNavigate('/privacy')}>Privacy</MenuItem>
            <MenuItem onClick={() => handleNavigate('/login')}>Login</MenuItem>
          </Menu>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Navigation;
