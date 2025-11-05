/**
 * Notices Page
 * Manage notices and announcements
 */

import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  Button,
  Box,
  Chip,
  CircularProgress,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
} from '@mui/icons-material';
import { noticeService } from '../services/notice.service';
import { Notice } from '../types';
import { useAuth } from '../contexts/AuthContext';
import { format } from 'date-fns';

const NoticesPage: React.FC = () => {
  const [notices, setNotices] = useState<Notice[]>([]);
  const [loading, setLoading] = useState(true);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingNotice, setEditingNotice] = useState<Notice | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    department: '',
    priority: 'medium' as 'high' | 'medium' | 'low',
  });
  const { currentUser } = useAuth();

  useEffect(() => {
    loadNotices();
  }, []);

  const loadNotices = async () => {
    try {
      const data = await noticeService.getNotices();
      setNotices(data);
    } catch (error) {
      console.error('Error loading notices:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDialog = (notice?: Notice) => {
    if (notice) {
      setEditingNotice(notice);
      setFormData({
        title: notice.title,
        content: notice.content,
        department: notice.department || '',
        priority: notice.priority,
      });
    } else {
      setEditingNotice(null);
      setFormData({
        title: '',
        content: '',
        department: '',
        priority: 'medium',
      });
    }
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingNotice(null);
  };

  const handleSave = async () => {
    if (!currentUser) return;

    try {
      if (editingNotice) {
        await noticeService.updateNotice(editingNotice.$id, formData);
      } else {
        // createdAt timestamp is set by the service layer
        await noticeService.createNotice({
          ...formData,
          authorId: currentUser.userId,
          authorName: currentUser.name,
          createdAt: '', // Will be set by service
          isActive: true,
        });
      }
      handleCloseDialog();
      loadNotices();
    } catch (error) {
      console.error('Error saving notice:', error);
    }
  };

  const handleDelete = async (noticeId: string) => {
    if (window.confirm('Are you sure you want to delete this notice?')) {
      try {
        await noticeService.deleteNotice(noticeId);
        loadNotices();
      } catch (error) {
        console.error('Error deleting notice:', error);
      }
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'error';
      case 'medium':
        return 'warning';
      case 'low':
      default:
        return 'default';
    }
  };

  if (loading) {
    return (
      <Container sx={{ display: 'flex', justifyContent: 'center', mt: 8 }}>
        <CircularProgress />
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4">Notice Management</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          Create Notice
        </Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Title</TableCell>
              <TableCell>Author</TableCell>
              <TableCell>Department</TableCell>
              <TableCell>Priority</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Created</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {notices.map((notice) => (
              <TableRow key={notice.$id}>
                <TableCell>{notice.title}</TableCell>
                <TableCell>{notice.authorName}</TableCell>
                <TableCell>{notice.department || 'All'}</TableCell>
                <TableCell>
                  <Chip
                    label={notice.priority}
                    color={getPriorityColor(notice.priority)}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  <Chip
                    label={notice.isActive ? 'Active' : 'Inactive'}
                    color={notice.isActive ? 'success' : 'default'}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  {format(new Date(notice.createdAt), 'MMM dd, yyyy')}
                </TableCell>
                <TableCell>
                  <IconButton
                    size="small"
                    onClick={() => handleOpenDialog(notice)}
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton
                    size="small"
                    onClick={() => handleDelete(notice.$id)}
                    color="error"
                  >
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Edit/Create Dialog */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>
          {editingNotice ? 'Edit Notice' : 'Create New Notice'}
        </DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Title"
            type="text"
            fullWidth
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Content"
            type="text"
            fullWidth
            multiline
            rows={6}
            value={formData.content}
            onChange={(e) => setFormData({ ...formData, content: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Department (optional)"
            type="text"
            fullWidth
            value={formData.department}
            onChange={(e) =>
              setFormData({ ...formData, department: e.target.value })
            }
            helperText="Leave empty to send to all departments"
          />
          <FormControl fullWidth margin="dense">
            <InputLabel>Priority</InputLabel>
            <Select
              value={formData.priority}
              label="Priority"
              onChange={(e) =>
                setFormData({
                  ...formData,
                  priority: e.target.value as 'high' | 'medium' | 'low',
                })
              }
            >
              <MenuItem value="low">Low</MenuItem>
              <MenuItem value="medium">Medium</MenuItem>
              <MenuItem value="high">High</MenuItem>
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Cancel</Button>
          <Button onClick={handleSave} variant="contained">
            {editingNotice ? 'Update' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default NoticesPage;
