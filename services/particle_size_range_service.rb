# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "../lib/config_text_field.rb"
require_relative "../lib/grid_bag_layout_helper.rb"

java_import "javax.swing.JLabel"

class ParticleSizeRangeService
  include GridBagLayoutHelper

  MAX_TEXT_FIELD_COUNT = 10

  def initialize(frame)
    @frame = frame
  end

  def call!
    add_component_with_constraints(0, 0, 1, 1) { JLabel.new 'particle size(area)(micro^2)' }
    add_component_with_constraints(0, 1, 1, 1) { JLabel.new '最小値' }
    add_component_with_constraints(1, 1, 1, 1) { ConfigTextField.new :particle_size_min, '', MAX_TEXT_FIELD_COUNT }
    add_component_with_constraints(0, 2, 1, 1) { JLabel.new '最大値' }
    add_component_with_constraints(1, 2, 1, 1) { ConfigTextField.new :particle_size_max, '', MAX_TEXT_FIELD_COUNT }

    @frame.get_content_pane.add panel
  end
end