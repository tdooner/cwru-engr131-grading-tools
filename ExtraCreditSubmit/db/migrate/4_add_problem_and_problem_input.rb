class AddProblemAndProblemInput < ActiveRecord::Migration
    def change
        add_column :submissions, :problem_id, :integer
        create_table :problems do |t|
            t.string :name
            t.text :description
            t.timestamps
        end
        create_table :problem_inputs do |t|
            t.integer :problem_id
            t.text :input
            t.text :expected_output
            t.integer :points
            t.timestamps
        end
    end
end
