# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./minmax_field"

class ContrastRangeField < MinmaxField
  set_constraints_position 0, 1, 1, 1

  def initialize(frame)
    super frame, 'Contrast', :contrast_min, :contrast_max
  end
end
