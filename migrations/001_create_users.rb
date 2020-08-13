Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      Integer :uid, null: false
      Integer :gid, null: false
      String :username, null: false, unique: true
      String :password, null: false
      String :home_dir, null: false
      String :forward_address
      TrueClass :forwarded, null: false, default: false
    end
  end

  down do
    drop_table :users
  end
end
