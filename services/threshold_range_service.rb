# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "../lib/config_text_field.rb"

java_import "javax.swing.JPanel"
java_import "javax.swing.JLable"
java_import "javax.swing.JTextField"

java_import "java.awt.GridBagLayout"
java_import "java.awt.GridBagConstraints"
java_import "java.awt.Insets"

class ThresholdRangeService < BaseService
  MAX_TEXT_FIELD_COUNT = 10

  def initialize(frame)
    super
    @frame = frame

    @layout = GridBagLayout.new
    @panel = JPanel.new @layout

    @constraints = GridBagConstraints.new
    @constraints.fill = GridBagConstraints.BOTH
  end

  def call!
    add_component_with_constraints(0, 0, 1, 2) { JLabel.new 'Threshold' }
    add_component_with_constraints(1, 0, 1, 1) { JLabel.new '最小値' }
    add_component_with_constraints(2, 0, 1, 1) { ConfigTextField.new :threshold_min, '', MAX_TEXT_FIELD_COUNT }
    add_component_with_constraints(1, 1, 1, 1) { JLabel.new '最大値' }
    add_component_with_constraints(2, 1, 1, 1) { ConfigTextField.new :threshold_max, '', MAX_TEXT_FIELD_COUNT }
  end

  private

  def add_component_with_constraints(gridx, gridy, gridwidth, gridheight, &block)
    @constraints.gridx = gridx
    @constraints.gridy = gridy
    @constraints.gridwidth = gridwidth
    @constraints.gridheight = gridheight

    component = block.call
    @layout.set_constraints component, @constraints
    @panel.add component
  end
end
