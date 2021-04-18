# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./minmax_field"

class ThresholdRangeField < MinmaxField
  set_constraints_position 0, 2, 2, 1
  set_padding_insets 0, 10, 5, 0

  def initialize(frame)
    super frame, 'Threshold', :threshold_min, :threshold_max
  end
end
