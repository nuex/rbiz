class RenameLineItemProductOptionSelectionVariation < ActiveRecord::Migration

  def self.up
    rename_column :line_items, :product_option_selection_id, :variation_id
  end

  def self.down
    rename_column :line_items, :variation_id, :product_option_selection_id
  end

end
