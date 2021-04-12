# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"
require_relative "./choose_image_directory.rb"
require_relative "./image_range_operator.rb"
require_relative "./image_contrast_operator.rb"

begin
  image_dir = ChooseImageDirectory.instance.run
  puts "Choosed image directory is #{image_dir}"

  ImageRangeOperator.new(image_dir).run
rescue => e
  # 何もしない
end
