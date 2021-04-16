require 'singleton'

class Config
  include Singleton

  COLUMN = %i[image_dir images contrast_min contrast_max page_number threshold_min threshold_max particle_size_min particle_size_max]

  attr_accessor *COLUMN

  def set?(column_name)
    return false unless COLUMN.include? column_name.to_sym

    !send(column_name).nil?
  end

  def method_missing(name, *args)
    return super if name !~ /\Aset_(.+?)\?\z/
    return super unless COLUMN.include? Regexp.last_matches[0]

    set? Regexp.last_matches[0]
  end
end
