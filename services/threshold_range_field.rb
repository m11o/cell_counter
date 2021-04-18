# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./minmax_field"

class ThresholdRangeField < MinmaxField
  def initialize(frame)
    super frame, 'Threshold', :threshold_min, :threshold_max
  end
end
