CREATE TABLE habit_templates (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT NOT NULL,
    icon       TEXT,
    color      TEXT,
    frequency  JSONB NOT NULL DEFAULT '{"type":"daily"}',
    note       TEXT,
    two_minute_version TEXT,
    category   TEXT NOT NULL DEFAULT 'General',
    sort_order INT NOT NULL DEFAULT 0
);

INSERT INTO habit_templates (name, icon, color, frequency, note, two_minute_version, category, sort_order) VALUES
  ('Sleep by 10pm',      '🌙', '#6366F1', '{"type":"daily"}', 'Consistent sleep improves everything', 'Put down your phone and lie down', 'Sleep', 0),
  ('No screens 1h before bed', '📵', '#8B5CF6', '{"type":"daily"}', 'Blue light disrupts melatonin', 'Dim the lights and read instead', 'Sleep', 1),
  ('Wake up at 7am',     '☀️', '#F59E0B', '{"type":"daily"}', 'Starting the day intentionally', 'Sit up before checking your phone', 'Sleep', 2),

  ('Drink 8 glasses of water', '💧', '#0EA5E9', '{"type":"daily"}', 'Hydration affects energy and focus', 'Fill a glass before your coffee', 'Body', 0),
  ('10-minute walk',     '🚶', '#10B981', '{"type":"daily"}', 'Movement resets mood and focus', 'Walk to the end of the street and back', 'Body', 1),
  ('Workout',            '🏋️', '#F43F5E', '{"type":"times_per_week","times":3}', 'Consistency beats intensity', 'Do 5 minutes of stretching', 'Body', 2),

  ('Morning journal',    '📓', '#A855F7', '{"type":"daily"}', 'Three sentences is enough', 'Write one thing you are grateful for', 'Mind', 0),
  ('Meditate',           '🧘', '#6366F1', '{"type":"daily"}', 'Even 5 minutes changes your day', 'Sit comfortably and take 5 deep breaths', 'Mind', 1),
  ('Read 20 minutes',    '📚', '#10B981', '{"type":"daily"}', 'Books compound over time', 'Read one page before sleeping', 'Mind', 2),

  ('Eat a vegetable',    '🥦', '#10B981', '{"type":"daily"}', 'Small steps toward better eating', 'Add spinach to whatever you are already eating', 'Nutrition', 0),
  ('No alcohol today',   '🚫', '#F59E0B', '{"type":"daily"}', 'Clarity is underrated', 'Drink sparkling water instead', 'Nutrition', 1),
  ('Cook at home',       '🍳', '#F43F5E', '{"type":"times_per_week","times":4}', 'Cheaper, healthier, and calming', 'Cook one thing you already know how to make', 'Nutrition', 2);
