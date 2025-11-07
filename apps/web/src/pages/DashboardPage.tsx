/**
 * Dashboard Page
 * Main dashboard showing analytics and quick actions
 */

import React, { useState, useEffect } from 'react';
import {
  Container,
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
  <Card
    sx={{
      background: `linear-gradient(135deg, ${color}0a 0%, ${color}05 100%)`,
      border: `1px solid ${color}20`,
      transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
      cursor: 'pointer',
      '&:hover': {
        transform: 'translateY(-8px)',
        boxShadow: `0 15px 40px ${color}30`,
        borderColor: `${color}40`,
      },
    }}
  >
    <CardContent>
      <Box display="flex" alignItems="center" mb={2}>
        <Box
          sx={{
            background: `linear-gradient(135deg, ${color}30, ${color}10)`,
            borderRadius: '12px',
            p: 1.5,
            mr: 2,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: `0 4px 15px ${color}20`,
          }}
        >
          {icon}
        </Box>
        <Typography variant="subtitle1" component="div" sx={{ fontWeight: 600 }}>
          {title}
        </Typography>
      </Box>
      <Typography 
        variant="h3" 
        component="div" 
        sx={{ 
          color: color,
          fontWeight: 800,
          mb: 1,
        }}
      >
        {value}
      </Typography>
      {subtitle && (
        <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>
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
      <Box sx={{ mb: 6 }}>
        <Typography 
          variant="h3" 
          gutterBottom 
          sx={{
            fontWeight: 800,
            fontSize: { xs: '2rem', md: '2.5rem' },
            background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
        >
          Dashboard Overview
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ fontSize: '1rem' }}>
          Real-time statistics and system insights
        </Typography>
      </Box>

      <Grid container spacing={3} sx={{ mb: 6 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Total Users"
            value={stats?.users.total || 0}
            icon={<PeopleIcon sx={{ fontSize: 28, color: '#6366f1' }} />}
            subtitle={`${stats?.users.students || 0} students, ${
              stats?.users.teachers || 0
            } teachers`}
            color="#6366f1"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Students"
            value={stats?.users.students || 0}
            icon={<SchoolIcon sx={{ fontSize: 28, color: '#10b981' }} />}
            subtitle="Enrolled students"
            color="#10b981"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Active Notices"
            value={stats?.notices.active || 0}
            icon={<AnnouncementIcon sx={{ fontSize: 28, color: '#f59e0b' }} />}
            subtitle={`${stats?.notices.highPriority || 0} high priority`}
            color="#f59e0b"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Messages"
            value={stats?.messages.total || 0}
            icon={<MessageIcon sx={{ fontSize: 28, color: '#06b6d4' }} />}
            subtitle={`${stats?.messages.unread || 0} unread`}
            color="#06b6d4"
          />
        </Grid>
      </Grid>

      <Grid container spacing={3}>
        <Grid size={{ xs: 12, md: 6 }}>
          <Card
            sx={{
              background: 'linear-gradient(135deg, #6366f10a 0%, #8b5cf60a 100%)',
              border: '1px solid rgba(99, 102, 241, 0.2)',
              transition: 'all 0.3s ease',
              '&:hover': {
                transform: 'translateY(-4px)',
                boxShadow: '0 10px 30px rgba(99, 102, 241, 0.1)',
              },
            }}
          >
            <CardContent>
              <Typography 
                variant="h6" 
                gutterBottom 
                sx={{ fontWeight: 700, color: '#1e293b' }}
              >
                System Overview
              </Typography>
              <Box sx={{ mt: 3, space: 2 }}>
                <Box sx={{ mb: 2, pb: 2, borderBottom: '1px solid rgba(99, 102, 241, 0.1)' }}>
                  <Typography variant="body2" sx={{ fontWeight: 600, color: '#6366f1', mb: 0.5 }}>
                    👥 Active Users
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {stats?.users.students || 0} students, {stats?.users.teachers || 0} teachers
                  </Typography>
                </Box>
                <Box sx={{ mb: 2, pb: 2, borderBottom: '1px solid rgba(99, 102, 241, 0.1)' }}>
                  <Typography variant="body2" sx={{ fontWeight: 600, color: '#8b5cf6', mb: 0.5 }}>
                    📢 Active Notices
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {stats?.notices.active || 0} notices ({stats?.notices.highPriority || 0} high priority)
                  </Typography>
                </Box>
                <Box>
                  <Typography variant="body2" sx={{ fontWeight: 600, color: '#d946ef', mb: 0.5 }}>
                    💬 Total Messages
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {stats?.messages.total || 0} messages ({stats?.messages.unread || 0} unread)
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid size={{ xs: 12, md: 6 }}>
          <Card
            sx={{
              background: 'linear-gradient(135deg, #ec48990a 0%, #f43f5e0a 100%)',
              border: '1px solid rgba(236, 72, 153, 0.2)',
              transition: 'all 0.3s ease',
              '&:hover': {
                transform: 'translateY(-4px)',
                boxShadow: '0 10px 30px rgba(236, 72, 153, 0.1)',
              },
            }}
          >
            <CardContent>
              <Typography 
                variant="h6" 
                gutterBottom 
                sx={{ fontWeight: 700, color: '#1e293b' }}
              >
                Quick Tips & Guides
              </Typography>
              <Box sx={{ mt: 3, space: 2 }}>
                {[
                  { icon: '🔍', text: 'Click on status chips to toggle active/inactive users' },
                  { icon: '🔎', text: 'Use the search bar to quickly find items' },
                  { icon: '🏷️', text: 'Filter users by role for better management' },
                  { icon: '📎', text: 'Attach files to notices for additional information' },
                ].map((tip, idx) => (
                  <Box 
                    key={idx}
                    sx={{ 
                      mb: 1.5, 
                      pb: 1.5,
                      borderBottom: idx < 3 ? '1px solid rgba(236, 72, 153, 0.1)' : 'none',
                      display: 'flex',
                      gap: 1.5,
                    }}
                  >
                    <Typography sx={{ fontSize: '1.2rem', flexShrink: 0 }}>{tip.icon}</Typography>
                    <Typography variant="body2" color="text.secondary">
                      {tip.text}
                    </Typography>
                  </Box>
                ))}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Container>
  );
};

export default DashboardPage;
