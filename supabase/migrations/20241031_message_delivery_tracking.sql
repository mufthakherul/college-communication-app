-- Message Delivery Tracking System
-- This migration adds tables for tracking message delivery status and typing indicators

-- Message delivery status table
CREATE TABLE IF NOT EXISTS message_delivery_status (
    message_id UUID PRIMARY KEY REFERENCES messages(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'sending',
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_status CHECK (status IN ('sending', 'sent', 'delivered', 'read', 'failed')),
    CONSTRAINT valid_timestamps CHECK (
        (sent_at IS NULL OR sent_at >= created_at) AND
        (delivered_at IS NULL OR delivered_at >= sent_at) AND
        (read_at IS NULL OR read_at >= delivered_at)
    )
);

-- Typing indicators table
CREATE TABLE IF NOT EXISTS typing_indicators (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    conversation_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'stopped',
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (user_id, conversation_id),
    CONSTRAINT valid_typing_status CHECK (status IN ('typing', 'stopped'))
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_message_delivery_recipient 
    ON message_delivery_status(recipient_id);

CREATE INDEX IF NOT EXISTS idx_message_delivery_status 
    ON message_delivery_status(status) WHERE status IN ('sending', 'sent');

CREATE INDEX IF NOT EXISTS idx_message_delivery_updated 
    ON message_delivery_status(updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_typing_indicators_conversation 
    ON typing_indicators(conversation_id) WHERE status = 'typing';

CREATE INDEX IF NOT EXISTS idx_typing_indicators_timestamp 
    ON typing_indicators(timestamp DESC) WHERE status = 'typing';

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER update_message_delivery_status_updated_at
    BEFORE UPDATE ON message_delivery_status
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to clean up old typing indicators
CREATE OR REPLACE FUNCTION cleanup_old_typing_indicators()
RETURNS void AS $$
BEGIN
    DELETE FROM typing_indicators
    WHERE timestamp < NOW() - INTERVAL '30 seconds'
    OR status = 'stopped';
END;
$$ LANGUAGE plpgsql;

-- Function to automatically update delivery status
CREATE OR REPLACE FUNCTION auto_update_delivery_status()
RETURNS TRIGGER AS $$
BEGIN
    -- When status changes to sent, set sent_at
    IF NEW.status = 'sent' AND OLD.status != 'sent' AND NEW.sent_at IS NULL THEN
        NEW.sent_at = NOW();
    END IF;
    
    -- When status changes to delivered, set delivered_at
    IF NEW.status = 'delivered' AND OLD.status != 'delivered' AND NEW.delivered_at IS NULL THEN
        NEW.delivered_at = NOW();
    END IF;
    
    -- When status changes to read, set read_at
    IF NEW.status = 'read' AND OLD.status != 'read' AND NEW.read_at IS NULL THEN
        NEW.read_at = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for auto-updating delivery timestamps
CREATE TRIGGER auto_update_delivery_timestamps
    BEFORE UPDATE ON message_delivery_status
    FOR EACH ROW
    EXECUTE FUNCTION auto_update_delivery_status();

-- Row Level Security (RLS) policies
ALTER TABLE message_delivery_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE typing_indicators ENABLE ROW LEVEL SECURITY;

-- Users can view their own delivery status
CREATE POLICY "Users can view own delivery status"
    ON message_delivery_status
    FOR SELECT
    USING (recipient_id = auth.uid());

-- Users can view delivery status for messages they sent
CREATE POLICY "Senders can view delivery status"
    ON message_delivery_status
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM messages
            WHERE messages.id = message_delivery_status.message_id
            AND messages.sender_id = auth.uid()
        )
    );

-- Users can insert/update their own delivery status
CREATE POLICY "Users can manage own delivery status"
    ON message_delivery_status
    FOR ALL
    USING (recipient_id = auth.uid())
    WITH CHECK (recipient_id = auth.uid());

-- Users can manage their own typing indicators
CREATE POLICY "Users can manage own typing indicators"
    ON typing_indicators
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Users can view typing indicators in their conversations
CREATE POLICY "Users can view conversation typing indicators"
    ON typing_indicators
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversations_participants cp
            WHERE cp.conversation_id = typing_indicators.conversation_id
            AND cp.user_id = auth.uid()
        )
    );

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON message_delivery_status TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON typing_indicators TO authenticated;

-- Comments for documentation
COMMENT ON TABLE message_delivery_status IS 'Tracks message delivery status with timestamps';
COMMENT ON TABLE typing_indicators IS 'Real-time typing indicators for conversations';
COMMENT ON COLUMN message_delivery_status.status IS 'Message status: sending, sent, delivered, read, failed';
COMMENT ON COLUMN typing_indicators.status IS 'Typing status: typing or stopped';

-- Create view for message delivery stats
CREATE OR REPLACE VIEW message_delivery_stats AS
SELECT 
    recipient_id,
    status,
    COUNT(*) as count,
    AVG(EXTRACT(EPOCH FROM (delivered_at - sent_at))) as avg_delivery_time_seconds,
    AVG(EXTRACT(EPOCH FROM (read_at - sent_at))) as avg_read_time_seconds
FROM message_delivery_status
WHERE sent_at IS NOT NULL
GROUP BY recipient_id, status;

COMMENT ON VIEW message_delivery_stats IS 'Statistics about message delivery performance';
