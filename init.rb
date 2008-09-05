# Require libraries we need
require 'csv'
require 'ostruct'
if ENV['RAILS_ENV'] == 'test'
  require 'test/spec'
  require 'mocha'
end

# 'directory' is defined in rails plugin loading, and since we are eval'd
# instead of required, we get it here.  But radiant seems to require or load
# instead of eval, so work with it.  Also it can be defined as a function during
# migrations for some reason.
unless defined?(directory) == 'local-variable'
  directory = File.dirname(__FILE__)
end

# Load the extension mojo that hacks into the rails base classes.
require File.join(directory, 'ext_lib', 'init.rb')

module ::Office ; end

# define some routes
ActionController::Routing::Routes.define_cart_routes do |map|

  map.connect 'cart/:action/:id', :controller => 'cart'
  map.connect 'browse/*slugs', :controller => 'cart', :action => 'tag'
  map.connect 'customer/:action/:id', :controller=>'customer'

  map.connect 'office', :controller => 'office/gateway', :action => 'index'

  map.namespace :office do |office|

    office.resources(
      :products,
      :member => {
        :available => :post,
        :featured => :post,
        :duplicate => :get,
        :tag => :post,
        :remove_image => :post,
        :update_matrix => :post
      },
      :has_many => [
        :product_images,
        :tag_activations,
        :tags,
        :tag_sets,
        :option_sets
      ]
    )

    office.resources(
      :product_images,
      :member => {
        :reorder => :post
      }
    )

    office.resources(
      :option_sets,
      :has_many => [
        :options
      ]
    )

    office.resources :tag_activations

    office.resources(
      :tag_sets,
      :has_many => [
        :tags
      ]
    )

    office.resources :tags

    office.resources :options

    office.resources :product_option_selections

    office.resources :cart_configs

    office.resources :customers

    office.resources :error_messages

    office.resources :coupons

    office.resources :carts

  end
#  map.connect 'browse/*slugs', :controller=>'cart', :action=>'tag'
#  map.connect 'product/:slug', :controller=>'cart', :action=>'product'
end

# Monkey patch into the core classes.
#
# There are two ways to do this, if you are patching into a core class
# like ActiveRecord::Base then you can include a class defined by a file
# in this plugin's lib directory
#
# ActiveRecord::Base.send :include, MyClassInLibDirectory
#
# If you are patching a class in the current application, such as a specific
# model that will get reloaded by the dependencies mechanism (in development
# mode) you will need your extension to be reloaded each time the application
# is reset, so use the hook we provide for you.
#
#Dependencies.register_cart_extension do
  # to add relationships, validations, etc
  # SomeModel.send :has_many, :my_model

  # to add new methods to instances of a class
  # define a module in lib/extensions/some_model_cart_extension
  # SomeModel.send :include, SomeModelCartExtension
  # SomeModel.new.my_mixed_in_method

  # to add new class methods
  # define a module in lib/extensions/some_model_cart_class_extension
  # SomeModel.send :include, SomeModelCartClassExtension
  # SomeModel.my_mixed_in_method
#end

# copy in assets
if ENV['RAILS_ENV'] == 'development'
  require 'fileutils'
  ['javascripts', 'stylesheets', 'images'].each do |type|
    r_path = File.join(RAILS_ROOT, 'public', type, 'cart')
    p_path = File.join(File.dirname(__FILE__), 'public', type, 'cart')
    unless File.directory?(r_path)
      FileUtils.mkdir_p(r_path)
    end
    Dir["#{p_path}/*"].each do |asset|
  #    unless File.exist?(File.join(r_path, File.basename(asset)))
        FileUtils.copy(asset, r_path)
  #    end
    end
  end
end
