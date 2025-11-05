/**
 * Dashboard Page
 * Main dashboard showing analytics and quick actions
 */

import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Card,
  CardContent,
  CircularProgress,
} from '@mui/material';
import Grid from '@mui/material/Grid2';
import {
  People as PeopleIcon,
  Announcement as AnnouncementIcon,
  Message as MessageIcon,
  School as SchoolIcon,
} from '@mui/icons-material';
import { userService } from '../services/user.service';
import { noticeService } from '../services/notice.service';
import { messageService } from '../services/message.service';

interface Stats {
  users: {
    total: number;
    students: number;
    teachers: number;
    admins: number;
  };
  notices: {
    total: number;
    active: number;
    highPriority: number;
  };
  messages: {
    total: number;
    read: number;
    unread: number;
  };
}

const StatCard: React.FC<{
  title: string;
  value: number;
  icon: React.ReactNode;
  subtitle?: string;
  color: string;
}> = ({ title, value, icon, subtitle, color }) => (
  <Card>
    <CardContent>
      <Box display="flex" alignItems="center" mb={2}>
        <Box
          sx={{
            backgroundColor: `${color}20`,
            borderRadius: '50%',
            p: 1,
            mr: 2,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          {icon}
        </Box>
        <Typography variant="h6" component="div">
          {title}
        </Typography>
      </Box>
      <Typography variant="h3" component="div" color={color}>
        {value}
      </Typography>
      {subtitle && (
        <Typography variant="body2" color="text.secondary" mt={1}>
          {subtitle}
        </Typography>
      )}
    </CardContent>
  </Card>
);

const DashboardPage: React.FC = () => {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const [userStats, noticeStats, messageStats] = await Promise.all([
        userService.getUserStats(),
        noticeService.getNoticeStats(),
        messageService.getMessageStats(),
      ]);

      setStats({
        users: userStats,
        notices: noticeStats,
        messages: messageStats,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
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
      <Typography variant="h4" gutterBottom>
        Dashboard Overview
      </Typography>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Total Users"
            value={stats?.users.total || 0}
            icon={<PeopleIcon color="primary" />}
            subtitle={`${stats?.users.students || 0} students, ${
              stats?.users.teachers || 0
            } teachers`}
            color="#1976d2"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Students"
            value={stats?.users.students || 0}
            icon={<SchoolIcon color="success" />}
            subtitle="Enrolled students"
            color="#2e7d32"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Active Notices"
            value={stats?.notices.active || 0}
            icon={<AnnouncementIcon color="warning" />}
            subtitle={`${stats?.notices.highPriority || 0} high priority`}
            color="#ed6c02"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Messages"
            value={stats?.messages.total || 0}
            icon={<MessageIcon color="info" />}
            subtitle={`${stats?.messages.unread || 0} unread`}
            color="#0288d1"
          />
        </Grid>
      </Grid>

      <Grid container spacing={3} sx={{ mt: 3 }}>
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Recent Activity
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Activity tracking coming soon...
            </Typography>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Quick Actions
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Use the navigation menu to manage users, notices, and messages.
            </Typography>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
};

export default DashboardPage;
