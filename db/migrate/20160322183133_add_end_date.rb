class AddEndDate < ActiveRecord::Migration
  def change
    change_table :festivals do |t|
      t.date :end_date
    end
  end
end




