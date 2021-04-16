# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./base_service.rb"

java_import "javax.swing.JComboBox"

class ImagePageService < BaseService
  def initialize(frame)
    super
    @frame = frame
  end

  def call!
    combo_box = JComboBox.new
    combo_box.add_item('')
    combo_box.add_item('all')
    (1..@config.max_slice_number).each { |page_number| combo_box.add_item(page_number.to_s) } if @config.set_max_slice_number? && !@config.max_slice_number.zero?

    @frame.get_content_pane.add combo_box
  end
end