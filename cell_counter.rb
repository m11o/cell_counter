# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"
require_relative "./ChooseImageDirectory.rb"
require_relative "./image_range_operator.rb"
require_relative "./image_contrast_operator.rb"

begin
  image_dir = ChooseImageDirectory.instance.run
  puts "Choosed image directory is #{image_dir}"

  #contrast_operator = ImageContrastOperator.new
  #contrast_operator.run

  ImageRangeOperator.new(image_dir).run
rescue => e
  # 何もしない
end
