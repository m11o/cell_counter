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
java_import "java.awt.Insets"

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
    add_component_with_constraints(0, 0, 1, 1) do |constraints|
      constraints.insets = build_padding_insets left: 10, right: 5, top: 10
      JLabel.new IMAGE_DIRECTORY_LABEL
    end
    add_component_with_constraints(1, 0, 1, 1) do
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
      @config.image_dir = file_chooser.get_selected_file.get_path
      @config.images = []
      Dir.glob("#{@config.image_dir}/*") { |image_path| @config.images << image_path }
      @selected = true

      add_component_with_constraints(0, 1, 2, 1) do |constraints|
        constraints.insets = build_padding_insets left: 10, right: 10, bottom: 5
        JLabel.new @config.image_dir
      end

      SelectedImagesService.new(panel).call!
      ImagePageService.new(panel).call!

      panel.updateUI
      @frame.pack
      @frame.repaint
    elsif selected == JFileChooser::CANCEL_OPTION
      @selected = false
    else
      @selected = false
      raise ChooseImageDirectoryException, ERROR_MESSAGE
    end
  end
end
