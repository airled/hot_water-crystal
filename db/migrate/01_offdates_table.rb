Sequel.migration do
  up do
    create_table :offdates do
      primary_key :id
      String :date
      index :date
    end
  end
  down do
    drop_table(:offdates)
  end
end  