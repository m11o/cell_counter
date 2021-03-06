require_relative "../lib/config_number_field.rb"
require_relative "../lib/grid_bag_layout_helper.rb"

java_import "javax.swing.JLabel"

class MinmaxField
  include GridBagLayoutHelper

  MAX_LABEL = '最大値'
  MIN_LABEL = '最小値'
  MAX_TEXT_FIELD_COUNT = 10

  def initialize(frame, title, min_field_name, max_field_name)
    @frame = frame
    @title = title
    @min_field_name = min_field_name
    @max_field_name = max_field_name
  end

  def draw!
    add_component_with_constraints(0, 0, 1, 1) { JLabel.new nl2br(@title) }
    add_component_with_constraints(0, 1, 1, 1) { JLabel.new MIN_LABEL }
    add_component_with_constraints(1, 1, 1, 1) { ConfigNumberField.new @min_field_name, '', MAX_TEXT_FIELD_COUNT }
    add_component_with_constraints(0, 2, 1, 1) { JLabel.new MAX_LABEL }
    add_component_with_constraints(1, 2, 1, 1) { ConfigNumberField.new @max_field_name, '', MAX_TEXT_FIELD_COUNT }

    @frame.add_component_with_constraints(*self.class.constraints_position) do |constraints|
      constraints.insets = build_padding_insets **self.class.padding_insets
      panel
    end
  end

  def self.set_constraints_position(grid_x, grid_y, grid_width, grid_height)
    class_eval do
      @grid_x = grid_x
      @grid_y = grid_y
      @grid_width = grid_width
      @grid_height = grid_height
    end
  end

  def self.set_padding_insets(top, left, bottom, right)
    class_eval do
      @padding_insets_value = { top: top, left: left, bottom: bottom, right: right }
    end
  end

  private

  def nl2br(label)
    return label if label !~ /\n/

    converted_label = label.gsub(/\n/, '<br />')
    "<html><body>#{converted_label}</body></html>"
  end

  def self.constraints_position
    [@grid_x, @grid_y, @grid_width, @grid_height]
  end

  def self.padding_insets
    @padding_insets_value
  end
end
