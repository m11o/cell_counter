# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./minmax_field"

class ContrastRangeField < MinmaxField
  def initialize(frame)
    super frame, 'Contrast', :contrast_min, :contrast_max
  end
end
