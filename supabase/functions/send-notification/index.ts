// Supabase Edge Function for sending notifications
// Helper function for notice notifications

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
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '', // Using service role for admin operations
    )

    const { noticeId, notice } = await req.json()

    // Get users matching target audience
    let query = supabaseClient
      .from('users')
      .select('id')
      .eq('is_active', true)

    if (notice.targetAudience && notice.targetAudience !== 'all') {
      query = query.eq('role', notice.targetAudience)
    }

    const { data: users } = await query

    if (!users || users.length === 0) {
      return new Response(
        JSON.stringify({ success: true, notificationsSent: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create notifications for all matching users
    const notifications = users.map(user => ({
      user_id: user.id,
      type: 'notice',
      title: notice.title,
      body: notice.content.substring(0, 100) + '...',
      data: {
        noticeId,
        type: notice.type
      },
      read: false
    }))

    const { error } = await supabaseClient
      .from('notifications')
      .insert(notifications)

    if (error) throw error

    return new Response(
      JSON.stringify({ success: true, notificationsSent: notifications.length }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
