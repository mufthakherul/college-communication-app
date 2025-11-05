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
} from '@mui/material';
import { messageService } from '../services/message.service';
import { Message } from '../types';
import { format } from 'date-fns';

const MessagesPage: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadMessages();
  }, []);

  const loadMessages = async () => {
    try {
      const data = await messageService.getMessages({ limit: 100 });
      setMessages(data);
    } catch (error) {
      console.error('Error loading messages:', error);
    } finally {
      setLoading(false);
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
        <Typography variant="h4">Message Monitoring</Typography>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Sender ID</TableCell>
              <TableCell>Receiver ID</TableCell>
              <TableCell>Message</TableCell>
              <TableCell>Timestamp</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {messages.map((message) => (
              <TableRow key={message.$id}>
                <TableCell>{message.senderId.substring(0, 8)}...</TableCell>
                <TableCell>{message.receiverId.substring(0, 8)}...</TableCell>
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

      {messages.length === 0 && (
        <Box textAlign="center" mt={4}>
          <Typography variant="body1" color="text.secondary">
            No messages found
          </Typography>
        </Box>
      )}
    </Container>
  );
};

export default MessagesPage;
