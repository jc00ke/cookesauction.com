migration 4, :create_pages do
  up do
    create_table :pages do
      column :id,           Integer, :serial => true
      column :title,        String
      column :keywords,     "TEXT"
      column :description,  "TEXT"
      column :content,      "TEXT"
      column :visible,      "Boolean"
      column :url,          URI
    end
  end

  down do
    drop_table :pages
  end
end
