require_relative './choose_image_directory_service'
require_relative './exception_dialog'
require_relative './contrast_range_field'
require_relative './particle_size_range_field'
require_relative './threshold_range_field'
require_relative '../lib/grid_bag_layout_helper'

java_import "javax.swing.JFrame"

java_import "java.awt.GridBagLayout"
java_import "java.awt.GridBagConstraints"

class MainFrame < JFrame
  include GridBagLayoutHelper

  attr_reader :layout, :constraints, :panel

  def initialize(title)
    super title

    @layout = GridBagLayout.new
    @constraints = GridBagConstraints.new
    @panel = get_content_pane
    @panel.set_layout(@layout)
  end

  def draw
    ChooseImageDirectoryService.new(self).call!
    ContrastRangeField.new(self).draw!
    ThresholdRangeField.new(self).draw!
    ParticleSizeRangeField.new(self).draw!

    pack
    set_visible(true)
  rescue => e
    puts e.message
    puts e.backtrace.join("\n")
    ExceptionDialog.call! self, 'エラーが発生しました'
  end
end
