# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

java_import "javax.swing.JPanel"

java_import "java.awt.GridBagLayout"
java_import "java.awt.GridBagConstraints"
java_import "java.awt.Insets"

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

  def add_component_with_constraints(gridx, gridy, gridwidth, gridheight, anchor = anchor_west, &block)
    constraints.gridx = gridx
    constraints.gridy = gridy
    constraints.gridwidth = gridwidth
    constraints.gridheight = gridheight
    constraints.anchor = anchor

    component = block.call constraints
    layout.set_constraints component, constraints
    panel.add component
  end

  def build_padding_insets(top: 0, left: 0, bottom: 0, right: 0)
    Insets.new top, left, bottom, right
  end

  def method_missing(name, *args)
    super if name !~ /\Aanchor_(.+?)\z/

    const_name = Regexp.last_match[1].upcase
    GridBagConstraints.const_get const_name.to_sym
  end
end
