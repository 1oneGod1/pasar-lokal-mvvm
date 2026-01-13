-- Dev-only schema bootstrap (runs automatically via docker-entrypoint-initdb.d)

CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price INTEGER NOT NULL CHECK (price >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO products (id, name, price)
VALUES
  ('prod-mango', 'Manis Medan Mango', 25000),
  ('prod-coffee', 'Lintong Coffee Beans', 78000)
ON CONFLICT (id) DO NOTHING;
