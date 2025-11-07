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
  Switch,
  FormControlLabel,
  Alert,
  LinearProgress,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  Search as SearchIcon,
  AttachFile as AttachFileIcon,
  Delete as DeleteFileIcon,
} from '@mui/icons-material';
import { noticeService } from '../services/notice.service';
import { storageService } from '../services/storage.service';
import { Notice } from '../types';
import { useAuth } from '../contexts/AuthContext';
import { format } from 'date-fns';
import Snackbar from '../components/Snackbar';
import { isRequired, isValidFileType, isValidFileSize, MAX_FILE_SIZE } from '../utils/validation';

const NoticesPage: React.FC = () => {
  const [notices, setNotices] = useState<Notice[]>([]);
  const [filteredNotices, setFilteredNotices] = useState<Notice[]>([]);
  const [loading, setLoading] = useState(true);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingNotice, setEditingNotice] = useState<Notice | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    department: '',
    priority: 'medium' as 'high' | 'medium' | 'low',
    isActive: true,
    attachments: [] as string[],
  });
  const [uploadingFiles, setUploadingFiles] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [searchTerm, setSearchTerm] = useState('');
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: '',
    severity: 'success' as 'success' | 'error' | 'info' | 'warning',
  });
  const { currentUser } = useAuth();

  useEffect(() => {
    loadNotices();
  }, []);

  useEffect(() => {
    // Filter notices based on search term
    if (searchTerm) {
      const filtered = notices.filter(
        (notice) =>
          notice.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
          notice.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
          notice.authorName.toLowerCase().includes(searchTerm.toLowerCase())
      );
      setFilteredNotices(filtered);
    } else {
      setFilteredNotices(notices);
    }
  }, [searchTerm, notices]);

  const loadNotices = async () => {
    try {
      const data = await noticeService.getNotices();
      setNotices(data);
      setFilteredNotices(data);
    } catch (error) {
      console.error('Error loading notices:', error);
      showSnackbar('Failed to load notices', 'error');
    } finally {
      setLoading(false);
    }
  };

  const showSnackbar = (
    message: string,
    severity: 'success' | 'error' | 'info' | 'warning' = 'success'
  ) => {
    setSnackbar({ open: true, message, severity });
  };

  const handleOpenDialog = (notice?: Notice) => {
    if (notice) {
      setEditingNotice(notice);
      setFormData({
        title: notice.title,
        content: notice.content,
        department: notice.department || '',
        priority: notice.priority,
        isActive: notice.isActive,
        attachments: notice.attachments || [],
      });
    } else {
      setEditingNotice(null);
      setFormData({
        title: '',
        content: '',
        department: '',
        priority: 'medium',
        isActive: true,
        attachments: [],
      });
    }
    setUploadingFiles(false);
    setUploadProgress(0);
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingNotice(null);
    setUploadingFiles(false);
    setUploadProgress(0);
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = event.target.files;
    if (!files || files.length === 0) return;

    // Validate files before upload
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      
      // Validate file type
      if (!isValidFileType(file.name)) {
        showSnackbar(
          `Invalid file type: ${file.name}. Please upload images, PDFs, or documents.`,
          'error'
        );
        event.target.value = '';
        return;
      }
      
      // Validate file size
      if (!isValidFileSize(file.size)) {
        showSnackbar(
          `File too large: ${file.name}. Maximum size is ${MAX_FILE_SIZE / 1024 / 1024}MB.`,
          'error'
        );
        event.target.value = '';
        return;
      }
    }

    setUploadingFiles(true);
    const uploadedFileIds: string[] = [];

    try {
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const fileId = await storageService.uploadNoticeAttachment(
          file,
          (progress) => {
            const totalProgress = ((i + progress / 100) / files.length) * 100;
            setUploadProgress(totalProgress);
          }
        );
        uploadedFileIds.push(fileId);
      }

      setFormData({
        ...formData,
        attachments: [...formData.attachments, ...uploadedFileIds],
      });
      showSnackbar(
        `${files.length} file(s) uploaded successfully`,
        'success'
      );
    } catch (error) {
      console.error('Error uploading files:', error);
      showSnackbar('Failed to upload files', 'error');
    } finally {
      setUploadingFiles(false);
      setUploadProgress(0);
      // Reset file input
      event.target.value = '';
    }
  };

  const handleRemoveAttachment = async (fileId: string) => {
    try {
      await storageService.deleteNoticeAttachment(fileId);
      setFormData({
        ...formData,
        attachments: formData.attachments.filter((id) => id !== fileId),
      });
      showSnackbar('Attachment removed successfully', 'success');
    } catch (error) {
      console.error('Error removing attachment:', error);
      showSnackbar('Failed to remove attachment', 'error');
    }
  };

  const handleSave = async () => {
    if (!currentUser) return;

    // Validate form data using shared validation utilities
    if (!isRequired(formData.title)) {
      showSnackbar('Title is required', 'error');
      return;
    }
    if (!isRequired(formData.content)) {
      showSnackbar('Content is required', 'error');
      return;
    }

    try {
      if (editingNotice) {
        await noticeService.updateNotice(editingNotice.$id, formData);
        showSnackbar('Notice updated successfully', 'success');
      } else {
        // createdAt timestamp will be set by the service layer
        await noticeService.createNotice({
          ...formData,
          authorId: currentUser.$id,
          authorName: currentUser.name,
          createdAt: new Date().toISOString(), // Temporary value, server will override
        });
        showSnackbar('Notice created successfully', 'success');
      }
      handleCloseDialog();
      loadNotices();
    } catch (error) {
      console.error('Error saving notice:', error);
      showSnackbar(
        `Failed to ${editingNotice ? 'update' : 'create'} notice`,
        'error'
      );
    }
  };

  const handleDelete = async (noticeId: string) => {
    if (window.confirm('Are you sure you want to delete this notice?')) {
      try {
        await noticeService.deleteNotice(noticeId);
        showSnackbar('Notice deleted successfully', 'success');
        loadNotices();
      } catch (error) {
        console.error('Error deleting notice:', error);
        showSnackbar('Failed to delete notice', 'error');
      }
    }
  };

  const handleToggleActive = async (notice: Notice) => {
    try {
      await noticeService.updateNotice(notice.$id, {
        isActive: !notice.isActive,
      });
      showSnackbar(
        `Notice ${!notice.isActive ? 'activated' : 'deactivated'} successfully`,
        'success'
      );
      loadNotices();
    } catch (error) {
      console.error('Error toggling notice status:', error);
      showSnackbar('Failed to update notice status', 'error');
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

      {/* Search bar */}
      <Box mb={3}>
        <TextField
          fullWidth
          placeholder="Search notices by title, content, or author..."
          variant="outlined"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          InputProps={{
            startAdornment: <SearchIcon sx={{ mr: 1, color: 'text.secondary' }} />,
          }}
        />
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
              <TableCell>Attachments</TableCell>
              <TableCell>Created</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredNotices.map((notice) => (
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
                    onClick={() => handleToggleActive(notice)}
                    sx={{ cursor: 'pointer' }}
                  />
                </TableCell>
                <TableCell>
                  {notice.attachments && notice.attachments.length > 0 ? (
                    <Chip
                      icon={<AttachFileIcon />}
                      label={notice.attachments.length}
                      size="small"
                      variant="outlined"
                    />
                  ) : (
                    '-'
                  )}
                </TableCell>
                <TableCell>
                  {format(new Date(notice.createdAt), 'MMM dd, yyyy')}
                </TableCell>
                <TableCell>
                  <IconButton
                    size="small"
                    onClick={() => handleOpenDialog(notice)}
                    title="Edit notice"
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton
                    size="small"
                    onClick={() => handleDelete(notice.$id)}
                    color="error"
                    title="Delete notice"
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
          <Alert severity="info" sx={{ mb: 2 }}>
            Fill in the notice details below. All fields marked with * are required.
          </Alert>
          <TextField
            autoFocus
            margin="dense"
            label="Title *"
            type="text"
            fullWidth
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            required
          />
          <TextField
            margin="dense"
            label="Content *"
            type="text"
            fullWidth
            multiline
            rows={6}
            value={formData.content}
            onChange={(e) => setFormData({ ...formData, content: e.target.value })}
            required
            helperText="Use markdown for formatting (e.g., **bold**, *italic*)"
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
          <FormControlLabel
            control={
              <Switch
                checked={formData.isActive}
                onChange={(e) =>
                  setFormData({ ...formData, isActive: e.target.checked })
                }
              />
            }
            label="Active"
            sx={{ mt: 2 }}
          />

          {/* File Upload Section */}
          <Box sx={{ mt: 3 }}>
            <Typography variant="subtitle2" gutterBottom>
              Attachments (Optional)
            </Typography>
            <Button
              variant="outlined"
              component="label"
              startIcon={<AttachFileIcon />}
              disabled={uploadingFiles}
              fullWidth
            >
              Upload Files
              <input
                type="file"
                hidden
                multiple
                accept="image/*,.pdf,.doc,.docx"
                onChange={handleFileUpload}
              />
            </Button>
            {uploadingFiles && (
              <Box sx={{ mt: 2 }}>
                <LinearProgress variant="determinate" value={uploadProgress} />
                <Typography variant="caption" color="text.secondary">
                  Uploading... {Math.round(uploadProgress)}%
                </Typography>
              </Box>
            )}
            {formData.attachments.length > 0 && (
              <List dense sx={{ mt: 2 }}>
                {formData.attachments.map((fileId, index) => (
                  <ListItem key={fileId}>
                    <ListItemText
                      primary={`Attachment ${index + 1}`}
                      secondary={fileId}
                    />
                    <ListItemSecondaryAction>
                      <IconButton
                        edge="end"
                        size="small"
                        onClick={() => handleRemoveAttachment(fileId)}
                        disabled={uploadingFiles}
                      >
                        <DeleteFileIcon />
                      </IconButton>
                    </ListItemSecondaryAction>
                  </ListItem>
                ))}
              </List>
            )}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog} disabled={uploadingFiles}>
            Cancel
          </Button>
          <Button
            onClick={handleSave}
            variant="contained"
            disabled={uploadingFiles}
          >
            {editingNotice ? 'Update' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Snackbar for notifications */}
      <Snackbar
        open={snackbar.open}
        message={snackbar.message}
        severity={snackbar.severity}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      />
    </Container>
  );
};

export default NoticesPage;
