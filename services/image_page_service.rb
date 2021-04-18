# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./base_service.rb"
require_relative "../lib/config_store"
require_relative "../lib/grid_bag_layout_helper"

java_import "javax.swing.JComboBox"
java_import "javax.swing.JLabel"

java_import "java.awt.event.ItemListener"
java_import "java.awt.event.ItemEvent"

class ImagePageService < BaseService
  include GridBagLayoutHelper

  def initialize(panel)
    super()
    @panel = panel
  end

  def call!
    add_component_with_constraints(0, 2, 1, 1) do |constraints|
      constraints.insets = build_padding_insets bottom: 5, left: 10, right: 5
      JLabel.new 'ページ指定'
    end
    add_component_with_constraints(1, 2, 1, 1) do |constraints|
      constraints.insets = build_padding_insets bottom: 5
      combo_box = JComboBox.new
      combo_box.add_item('')
      combo_box.add_item('all')
      (1..@config.max_slice_number).each { |page_number| combo_box.add_item(page_number.to_s) } if @config.set_max_slice_number? && !@config.max_slice_number.zero?

      update_combo_box_size combo_box, width: 190.0

      combo_box.add_item_listener ImagePageSelectedListener.new
      combo_box
    end
  end

  # @Override
  def panel
    @panel
  end

  # @Override
  def layout
    @panel.get_layout
  end

  private

  def update_combo_box_size(combo_box, width: nil, height: nil)
    return if width.nil? && height.nil?

    dimension = combo_box.get_preferred_size

    width = dimension.get_width if width.nil?
    height = dimension.get_height if height.nil?

    dimension.set_size width, height
    combo_box.set_preferred_size dimension
  end

  class ImagePageSelectedListener
    include ItemListener

    def initialize
      @config = ConfigStore.instance
    end

    def item_state_changed(event)
      return if event.get_state_change != ItemEvent.SELECTED

      item = event.get_item
      @config.page_number = item
    end
  end
end
