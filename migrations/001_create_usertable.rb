Sequel.migration do
  up do

    create_table(:users) do
      primary_key :id

      String :username
      String :password
    end
    create_table(:threads) do
      primary_key :thread_id

      String :thread_name
    end
    create_table(:posts) do
      primary_key :post_id
      String :thread_overlord
      String :user_overlord
      String :actual_post
    end
  end


  down do

    drop_table(:users)
    drop_table(:threads)
    drop_table(:posts)

  end
end