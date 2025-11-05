/**
 * Snackbar Component
 * Reusable toast notification component
 */

import React from 'react';
import {
  Snackbar as MuiSnackbar,
  Alert,
  AlertColor,
} from '@mui/material';

interface SnackbarProps {
  open: boolean;
  message: string;
  severity?: AlertColor;
  onClose: () => void;
}

const Snackbar: React.FC<SnackbarProps> = ({
  open,
  message,
  severity = 'success',
  onClose,
}) => {
  return (
    <MuiSnackbar
      open={open}
      autoHideDuration={6000}
      onClose={onClose}
      anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
    >
      <Alert onClose={onClose} severity={severity} sx={{ width: '100%' }}>
        {message}
      </Alert>
    </MuiSnackbar>
  );
};

export default Snackbar;
