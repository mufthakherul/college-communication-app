// Supabase Edge Function for generating analytics reports
// Replaces Firebase Cloud Function: generateAnalyticsReport

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get authenticated user
    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if user is admin
    const { data: userData } = await supabaseClient
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single()

    if (!userData || userData.role !== 'admin') {
      return new Response(
        JSON.stringify({ error: 'Insufficient permissions' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse request
    const { reportType, startDate, endDate } = await req.json()

    let report = {}

    switch (reportType) {
      case 'user_activity':
        report = await generateUserActivityReport(supabaseClient, startDate, endDate)
        break
      case 'notices':
        report = await generateNoticesReport(supabaseClient, startDate, endDate)
        break
      case 'messages':
        report = await generateMessagesReport(supabaseClient, startDate, endDate)
        break
      default:
        return new Response(
          JSON.stringify({ error: 'Invalid report type' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }

    return new Response(
      JSON.stringify({ success: true, report }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

async function generateUserActivityReport(client: any, startDate: string, endDate: string) {
  const { data: activities } = await client
    .from('user_activity')
    .select('*')
    .gte('created_at', startDate)
    .lte('created_at', endDate)

  const uniqueUsers = new Set(activities?.map((a: any) => a.user_id) || [])
  
  return {
    totalActivities: activities?.length || 0,
    uniqueUsers: uniqueUsers.size,
    topActions: getTopActions(activities || []),
    dailyBreakdown: getDailyBreakdown(activities || [])
  }
}

async function generateNoticesReport(client: any, startDate: string, endDate: string) {
  const { data: notices } = await client
    .from('notices')
    .select('*')
    .gte('created_at', startDate)
    .lte('created_at', endDate)

  return {
    totalNotices: notices?.length || 0,
    activeNotices: notices?.filter((n: any) => n.is_active).length || 0,
    byType: getNoticesByType(notices || []),
    byAuthor: getNoticesByAuthor(notices || [])
  }
}

async function generateMessagesReport(client: any, startDate: string, endDate: string) {
  const { data: messages } = await client
    .from('messages')
    .select('*')
    .gte('created_at', startDate)
    .lte('created_at', endDate)

  return {
    totalMessages: messages?.length || 0,
    readMessages: messages?.filter((m: any) => m.read).length || 0,
    byType: getMessagesByType(messages || [])
  }
}

function getTopActions(activities: any[]) {
  const actionCounts: { [key: string]: number } = {}
  activities.forEach(activity => {
    const action = activity.activity_type
    actionCounts[action] = (actionCounts[action] || 0) + 1
  })
  
  return Object.entries(actionCounts)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 10)
    .map(([action, count]) => ({ action, count }))
}

function getDailyBreakdown(activities: any[]) {
  const dailyCounts: { [key: string]: number } = {}
  activities.forEach(activity => {
    const date = new Date(activity.created_at).toDateString()
    dailyCounts[date] = (dailyCounts[date] || 0) + 1
  })
  
  return dailyCounts
}

function getNoticesByType(notices: any[]) {
  const typeCounts: { [key: string]: number } = {}
  notices.forEach(notice => {
    typeCounts[notice.type] = (typeCounts[notice.type] || 0) + 1
  })
  
  return typeCounts
}

function getNoticesByAuthor(notices: any[]) {
  const authorCounts: { [key: string]: number } = {}
  notices.forEach(notice => {
    authorCounts[notice.author_id] = (authorCounts[notice.author_id] || 0) + 1
  })
  
  return authorCounts
}

function getMessagesByType(messages: any[]) {
  const typeCounts: { [key: string]: number } = {}
  messages.forEach(message => {
    typeCounts[message.type] = (typeCounts[message.type] || 0) + 1
  })
  
  return typeCounts
}
