class TestModel
  include ActiveModel::Model
  attr_accessor :id
  def is_a?(klass)
    klass == ActiveRecord::Base
  end
end
