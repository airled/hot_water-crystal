Sequel.migration do
  up do
    create_table :addresses do
      primary_key :id
      Integer :offdate_id
      String :street
      String :house
      index :street
    end
  end
  down do
    drop_table(:addresses)
  end
end  