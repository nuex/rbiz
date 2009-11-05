class AddToggleMergingAbandonedCartConfig < ActiveRecord::Migration

  def self.up
    cc = CartConfig.new(:value => true, :name => 'merge_abandoned_cart')
    cc.send(:save!)
  end

  def self.down
    cc = CartConfig.find_by_name('merge_abandoned_cart')
    cc.delete if cc
  end

end
