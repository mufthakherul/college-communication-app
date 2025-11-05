/**
 * Messages Page
 * Monitor and view messages between users
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
  Box,
  Chip,
  CircularProgress,
  Tooltip,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from '@mui/material';
import { Search as SearchIcon } from '@mui/icons-material';
import { messageService } from '../services/message.service';
import { userService } from '../services/user.service';
import { Message, User } from '../types';
import { format } from 'date-fns';

const MessagesPage: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [filteredMessages, setFilteredMessages] = useState<Message[]>([]);
  const [users, setUsers] = useState<Map<string, User>>(new Map());
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'read' | 'unread'>('all');

  useEffect(() => {
    loadMessages();
  }, []);

  useEffect(() => {
    // Filter messages based on search term and status
    let filtered = messages;

    if (searchTerm) {
      filtered = filtered.filter(
        (message) =>
          message.message.toLowerCase().includes(searchTerm.toLowerCase()) ||
          getUserName(message.senderId)
            .toLowerCase()
            .includes(searchTerm.toLowerCase()) ||
          getUserName(message.receiverId)
            .toLowerCase()
            .includes(searchTerm.toLowerCase())
      );
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter((message) =>
        statusFilter === 'read' ? message.isRead : !message.isRead
      );
    }

    setFilteredMessages(filtered);
  }, [searchTerm, statusFilter, messages]);

  const loadMessages = async () => {
    try {
      const [messagesData, usersData] = await Promise.all([
        messageService.getMessages({ limit: 100 }),
        userService.getUsers(),
      ]);
      
      // Create a map of userId to user for quick lookup
      const userMap = new Map(usersData.map(u => [u.userId, u]));
      
      setMessages(messagesData);
      setFilteredMessages(messagesData);
      setUsers(userMap);
    } catch (error) {
      console.error('Error loading messages:', error);
    } finally {
      setLoading(false);
    }
  };

  const getUserName = (userId: string): string => {
    const user = users.get(userId);
    return user?.name || 'Unknown User';
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
        <Typography variant="h4">Message Monitoring</Typography>
        <Typography variant="body2" color="text.secondary">
          Total: {filteredMessages.length} of {messages.length} messages
        </Typography>
      </Box>

      {/* Search and Filter */}
      <Box mb={3} display="flex" gap={2}>
        <TextField
          fullWidth
          placeholder="Search messages by content, sender, or receiver..."
          variant="outlined"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          InputProps={{
            startAdornment: <SearchIcon sx={{ mr: 1, color: 'text.secondary' }} />,
          }}
        />
        <FormControl sx={{ minWidth: 150 }}>
          <InputLabel>Status</InputLabel>
          <Select
            value={statusFilter}
            label="Status"
            onChange={(e) =>
              setStatusFilter(e.target.value as 'all' | 'read' | 'unread')
            }
          >
            <MenuItem value="all">All</MenuItem>
            <MenuItem value="read">Read</MenuItem>
            <MenuItem value="unread">Unread</MenuItem>
          </Select>
        </FormControl>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Sender</TableCell>
              <TableCell>Receiver</TableCell>
              <TableCell>Message</TableCell>
              <TableCell>Timestamp</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredMessages.map((message) => (
              <TableRow key={message.$id}>
                <TableCell>
                  <Tooltip title={`ID: ${message.senderId}`}>
                    <span>{getUserName(message.senderId)}</span>
                  </Tooltip>
                </TableCell>
                <TableCell>
                  <Tooltip title={`ID: ${message.receiverId}`}>
                    <span>{getUserName(message.receiverId)}</span>
                  </Tooltip>
                </TableCell>
                <TableCell>
                  {message.message.length > 50
                    ? `${message.message.substring(0, 50)}...`
                    : message.message}
                </TableCell>
                <TableCell>
                  {format(new Date(message.timestamp), 'MMM dd, yyyy HH:mm')}
                </TableCell>
                <TableCell>
                  <Chip
                    label={message.isRead ? 'Read' : 'Unread'}
                    color={message.isRead ? 'success' : 'default'}
                    size="small"
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {!loading && filteredMessages.length === 0 && (
        <Box textAlign="center" mt={4}>
          <Typography variant="body1" color="text.secondary">
            {messages.length === 0
              ? 'No messages found'
              : 'No messages match your search criteria'}
          </Typography>
        </Box>
      )}
    </Container>
  );
};

export default MessagesPage;
