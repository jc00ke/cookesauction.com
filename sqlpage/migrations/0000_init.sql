CREATE TABLE IF NOT EXISTS [sales] (
   [slug] TEXT PRIMARY KEY,
   [street_address] TEXT,
   [city] TEXT,
   [state] TEXT,
   [zip] TEXT,
   [location] TEXT,
   [number_photos] INTEGER,
   [starting_at] TEXT,
   [type] TEXT,
   [title] TEXT,
   [content] TEXT,
   [visible] INTEGER,
   [result] TEXT,
   [update_text] TEXT,
   [hide_photos] INTEGER,
   [custom_card_photo] INTEGER,
   [inline_image_list] TEXT
);
