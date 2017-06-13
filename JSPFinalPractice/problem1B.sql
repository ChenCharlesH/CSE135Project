CREATE INDEX idx_follower
ON following (follower);

CREATE INDEX idx_followee
ON following (followee);

CREATE INDEX idx_vlikes
ON likes (video);

CREATE INDEX idx_uname
ON user (name);
