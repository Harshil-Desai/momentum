-- Seed a development user for local testing
-- Password: momentum123 (bcrypt hash)
INSERT INTO users (email, password_hash)
VALUES (
    'harshil.desai@gasleaksensors.com',
    '$2a$10$OZvOW5wfAxFSgtgAcLyw7uHRI/ImE1Rmk8CWUpBicbbdAT2kBZ0wm'
)
ON CONFLICT (email) DO NOTHING;
