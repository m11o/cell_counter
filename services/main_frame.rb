# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative './choose_image_directory_service'
require_relative './exception_dialog'
require_relative './contrast_range_service'
require_relative './particle_size_range_service'
require_relative './threshold_range_service'

java_import "javax.swing.JFrame"

java_import "java.awt.GridLayout"

class MainFrame < JFrame
  def initialize(title)
    super title

    set_default_close_operation(EXIT_ON_CLOSE)
    @pane = get_content_pane
    @pane.set_layout(GridLayout.new(4, 1))
  end

  def draw
    ChooseImageDirectoryService.new(self).call!
    ContrastRangeService.new(self).call!
    ThresholdRangeService.new(self).call!
    ParticleSizeRangeService.new(self).call!

    pack
    set_visible(true)
  rescue => e
    puts e.message
    puts e.backtrace.join("\n")
    ExceptionDialog.call! self, 'エラーが発生しました'
  end
end
