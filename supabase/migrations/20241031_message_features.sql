-- Message Attachments and Reactions
-- Adds support for file attachments and emoji reactions to messages

-- Add attachment columns to messages table
ALTER TABLE messages
ADD COLUMN IF NOT EXISTS attachment_url TEXT,
ADD COLUMN IF NOT EXISTS attachment_name TEXT,
ADD COLUMN IF NOT EXISTS attachment_size INTEGER,
ADD COLUMN IF NOT EXISTS thumbnail_url TEXT,
ADD COLUMN IF NOT EXISTS metadata JSONB;

-- Add new message types
COMMENT ON COLUMN messages.type IS 'Message type: text, image, file, video, audio, document';

-- Message reactions table
CREATE TABLE IF NOT EXISTS message_reactions (
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    reaction TEXT NOT NULL CHECK (reaction IN ('like', 'love', 'laugh', 'wow', 'sad', 'angry', 'fire', 'celebrate', 'thumbsDown', 'clap')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (message_id, user_id)
);

-- Indexes for reactions
CREATE INDEX IF NOT EXISTS idx_message_reactions_message 
    ON message_reactions(message_id);

CREATE INDEX IF NOT EXISTS idx_message_reactions_user 
    ON message_reactions(user_id);

CREATE INDEX IF NOT EXISTS idx_message_reactions_created 
    ON message_reactions(created_at DESC);

-- Storage bucket for message attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('message-attachments', 'message-attachments', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for message attachments
CREATE POLICY "Users can upload their own attachments"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'message-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view message attachments"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'message-attachments');

CREATE POLICY "Users can delete their own attachments"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'message-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Row Level Security for reactions
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;

-- Users can view all reactions
CREATE POLICY "Users can view all reactions"
    ON message_reactions FOR SELECT
    USING (true);

-- Users can add their own reactions
CREATE POLICY "Users can add own reactions"
    ON message_reactions FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- Users can update their own reactions
CREATE POLICY "Users can update own reactions"
    ON message_reactions FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Users can delete their own reactions
CREATE POLICY "Users can delete own reactions"
    ON message_reactions FOR DELETE
    USING (user_id = auth.uid());

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_message_reactions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for auto-updating updated_at
CREATE TRIGGER update_message_reactions_timestamp
    BEFORE UPDATE ON message_reactions
    FOR EACH ROW
    EXECUTE FUNCTION update_message_reactions_updated_at();

-- Function to get reaction summary for a message
CREATE OR REPLACE FUNCTION get_message_reaction_summary(message_uuid UUID)
RETURNS TABLE (
    reaction TEXT,
    count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mr.reaction,
        COUNT(*) as count
    FROM message_reactions mr
    WHERE mr.message_id = message_uuid
    GROUP BY mr.reaction
    ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON message_reactions TO authenticated;
GRANT EXECUTE ON FUNCTION get_message_reaction_summary(UUID) TO authenticated;

-- Comments for documentation
COMMENT ON TABLE message_reactions IS 'Emoji reactions to messages';
COMMENT ON COLUMN message_reactions.reaction IS 'Reaction type: like, love, laugh, wow, sad, angry, fire, celebrate, thumbsDown, clap';
COMMENT ON FUNCTION get_message_reaction_summary(UUID) IS 'Get reaction counts for a message';

-- Create view for messages with reaction counts
CREATE OR REPLACE VIEW messages_with_reactions AS
SELECT 
    m.*,
    COUNT(DISTINCT mr.user_id) as reaction_count,
    json_agg(
        json_build_object(
            'reaction', mr.reaction,
            'user_id', mr.user_id,
            'user_name', mr.user_name
        )
    ) FILTER (WHERE mr.user_id IS NOT NULL) as reactions
FROM messages m
LEFT JOIN message_reactions mr ON m.id = mr.message_id
GROUP BY m.id;

COMMENT ON VIEW messages_with_reactions IS 'Messages with aggregated reaction data';

-- Grant view permissions
GRANT SELECT ON messages_with_reactions TO authenticated;
