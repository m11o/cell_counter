# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./selected_images_service.rb"
require_relative "./image_page_service.rb"
require_relative "./base_service.rb"
require_relative "../lib/grid_bag_layout_helper"
require_relative "../lib/config_text_field"

java_import "javax.swing.JLabel"
java_import "javax.swing.JButton"
java_import "javax.swing.JFileChooser"

java_import "java.awt.event.ActionListener"

class ChooseImageDirectoryException < StandardError; end

class ChooseImageDirectoryService < BaseService
  include ActionListener
  include GridBagLayoutHelper

  IMAGE_DIRECTORY_LABEL = '画像フォルダ'.freeze
  ERROR_MESSAGE = 'エラーが発生しました。時間を置いてから再度実行してください'

  attr_reader :images

  def initialize(frame)
    super()
    @frame = frame
    @selected = false
  end

  def call!
    add_component_with_constraints(0, 0, 1, 1) { JLabel.new IMAGE_DIRECTORY_LABEL }
    add_component_with_constraints(1, 0, 1, 1) { ConfigTextField.new(:image_dir) }
    add_component_with_constraints(2, 0, 1, 1) do
      button = JButton.new('フォルダ選択')
      button.add_action_listener(self)
      button
    end

    @frame.add panel
  end

  def panel
    super
  end

  def selected?
    @selected
  end

  private

  def action_performed(_event)
    file_chooser = JFileChooser.new
    file_chooser.set_file_selection_mode JFileChooser::DIRECTORIES_ONLY

    selected = file_chooser.show_open_dialog(@frame)
    if selected == JFileChooser::APPROVE_OPTION
      @config.images = file_chooser.get_selected_files
      @selected = true

      SelectedImagesService.new(@frame).call!
      ImagePageService.new(@frame).call!

      @frame.repaint
    elsif selected == JFileChooser::CANCEL_OPTION
      @selected = false
    else
      @selected = false
      raise ChooseImageDirectoryException, ERROR_MESSAGE
    end
  end
end
