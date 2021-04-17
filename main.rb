# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative './services/choose_image_directory_service'
require_relative './services/exception_dialog'
require_relative './services/contrast_range_service'
require_relative './services/particle_size_range_service'
require_relative './services/threshold_range_service'

java_import "javax.swing.JFrame"
java_import "java.awt.FlowLayout"

frame = JFrame.new 'multiply cell counter'
frame.set_layout(FlowLayout.new)
frame.set_size(500, 500)
begin
  ChooseImageDirectoryService.new(frame).call!
  ContrastRangeService.new(frame).call!
  ThresholdRangeService.new(frame).call!
  ParticleSizeRangeService.new(frame).call!

  frame.pack
  frame.set_visible(true)
rescue => e
  puts e
  puts e.backtrace.join("\n")
  ExceptionDialog.call! frame, 'エラーが発生しました'
end
