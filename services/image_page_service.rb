# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./base_service.rb"
require_relative "../lib/config"

java_import "javax.swing.JComboBox"
java_import "java.awt.event.ItemListener"
java_import "java.awt.event.ItemEvent"

class ImagePageService < BaseService
  def initialize(frame)
    super()
    @frame = frame
  end

  def call!
    combo_box = JComboBox.new
    combo_box.add_item('')
    combo_box.add_item('all')
    (1..@config.max_slice_number).each { |page_number| combo_box.add_item(page_number.to_s) } if @config.set_max_slice_number? && !@config.max_slice_number.zero?

    combo_box.add_item_listener ImagePageSelectedListener.new

    @frame.get_content_pane.add combo_box
  end

  class ImagePageSelectedListener
    include ItemListener

    def initialize
      @config = Config.instance
    end

    def item_state_changed(event)
      return if event.get_state_change != ItemEvent.SELECTED

      item = event.get_item
      @config.page_number = item
    end
  end
end
