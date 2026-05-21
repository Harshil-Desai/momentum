INSERT INTO achievements (id, name, description, icon, criteria, sort_order) VALUES
('first_steps',    'First Steps',     'Complete your first check-in',                  '🌱', '{"type":"checkin_count","target":1}',                1),
('week_one',       'Week One',        'Maintain a 7-day streak',                       '🔥', '{"type":"streak","target":7}',                       2),
('in_the_flow',    'In the Flow',     'Maintain a 30-day streak',                      '⚡', '{"type":"streak","target":30}',                      3),
('perfect_week',   'Perfect Week',    'Complete every habit for 7 consecutive days',   '✨', '{"type":"perfect_week"}',                            4),
('the_comeback',   'The Comeback',    'Rebuild a 14-day streak after breaking one',    '💪', '{"type":"comeback","streak_threshold":14}',           5),
('early_bird',     'Early Bird',      'Check in before 8AM on 10 separate days',       '🌅', '{"type":"time_of_day","hour_before":8,"target":10}',  6),
('night_owl',      'Night Owl',       'Check in after 10PM on 10 separate days',       '🌙', '{"type":"time_of_day","hour_after":22,"target":10}',  7),
('the_philosopher','The Philosopher', 'Write 10 weekly reflections',                   '📝', '{"type":"reflection_count","target":10}',             8);
