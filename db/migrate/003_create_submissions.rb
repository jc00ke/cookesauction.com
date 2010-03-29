migration 3, :create_submissions do
  up do
    create_table :submissions do
      column :id, Integer, :serial => true
      column :name, String
      column :email, String
      column :comment, "TEXT"
      column :created_at, DateTime
    end
  end

  down do
    drop_table :submissions
  end
end
