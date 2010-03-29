migration 2, :create_emails do
  up do
    create_table :emails do
      column :id, Integer, :serial => true
      column :name, String
      column :email, String
    end
  end

  down do
    drop_table :emails
  end
end
