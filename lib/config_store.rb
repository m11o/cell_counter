# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require 'singleton'

class ConfigStore
  include Singleton

  COLUMN = %i[image_dir images contrast_min contrast_max page_number threshold_min threshold_max particle_size_min particle_size_max max_slice_number]

  attr_accessor *COLUMN

  def set?(column_name)
    return false unless COLUMN.include? column_name.to_sym

    !send(column_name).nil?
  end

  def method_missing(name, *args)
    return super if name !~ /\Aset_(.+?)\?\z/

    column_name = Regexp.last_match[1].to_sym
    return super unless COLUMN.include? column_name

    set? column_name
  end
end
