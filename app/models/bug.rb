class Bug < ApplicationRecord
  has_one :state

  validates_presence_of :app_token, :status, :priority, :comment
end
