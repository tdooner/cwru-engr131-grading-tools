class AddSubmissions < ActiveRecord::Migration
    def change
        create_table(:submissions) do |t|
            t.column :case_id, :string
            t.column :code, :text
            t.column :score, :integer
            t.column :created_at, :datetime
            t.column :updated_at, :datetime
        end
    end
end
