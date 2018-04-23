class Trip < ActiveRecord::Base
	belongs_to :guide
	belongs_to :city
end
