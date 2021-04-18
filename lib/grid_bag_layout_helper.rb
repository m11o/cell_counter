# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

java_import "javax.swing.JPanel"

java_import "java.awt.GridBagLayout"
java_import "java.awt.GridBagConstraints"

module GridBagLayoutHelper
  def layout
    @layout ||= GridBagLayout.new
  end

  def panel
    @panel ||= JPanel.new layout
  end

  def constraints
    @constraints ||= GridBagConstraints.new
  end

  def add_component_with_constraints(gridx, gridy, gridwidth, gridheight, &block)
    constraints.gridx = gridx
    constraints.gridy = gridy
    constraints.gridwidth = gridwidth
    constraints.gridheight = gridheight

    component = block.call constraints
    layout.set_constraints component, constraints
    panel.add component
  end
end
