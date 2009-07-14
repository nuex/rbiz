context 'A new tag' do
  setup do
    CartLib.activate_test_stubs

    TagSet.delete_all
    Tag.delete_all

    @ts1 = TagSet.create(:name=>'one')
    @t1 = Tag.create!(:tag_set => @ts1, :name => 'tt')
    @t2 = Tag.create!(:tag_set => @ts1, :name => 'tt2')
  end

  specify 'should automatically set slug' do
    assert !@t1.slug.nil?
    assert !@t1.slug.empty?
    assert_equal @t1.slug, 'tt'
  end
  
  specify 'should return all tags for slugs' do
    @taglist = Tag.for_slugs ['tt', 'tt2']
    assert_equal @taglist, [@t1, @t2]
  end

  specify 'should not set an emtpy slug' do
    @t1.slug = ""
    assert !@t1.slug.nil?
    assert !@t1.slug.empty?
    @t1.slug = nil
    assert !@t1.slug.nil?
    assert !@t1.slug.empty?
  end
end

context 'The Tag class' do
  setup do

    TagSet.delete_all
    Tag.delete_all
    Product.delete_all

    CartLib.activate_test_stubs

    @product = Product.create!(:name=>'1',:sku=>'1',:price=>1,:quantity=>1)

    @ts1 = TagSet.create!(:name=>'one')
    @t1 = Tag.create!(:tag_set => @ts1, :name => 'tt')
    @t2 = Tag.create!(:tag_set => @ts1, :name => '22')

    @ts2 = TagSet.create!(:name=>'two')
    @t3 = Tag.create!(:tag_set => @ts2, :name => '33 another set')
  end

  specify 'finds related tags that share any product with a given set of tags' do
    @product.effective_on = Date.today - 10
    @product.tag_activations.create!(:tag => @t1)
    @product.tag_activations.create!(:tag => @t2)
    @product.tag_activations.create!(:tag => @t3)
    @product.save
    assert !Product.find_ids_by_tags(@t1).empty?
    rv = Tag.related_for @t1
    assert_kind_of Hash, rv
    assert_equal 2, rv.keys.length, rv.inspect
    assert rv[@ts1]
    assert rv[@ts2]
    assert_kind_of Array, rv[@ts1]
    assert_equal 1, rv[@ts1].length
    assert_equal @t2, rv[@ts1].first
  end
end
