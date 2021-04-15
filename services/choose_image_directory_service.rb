# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "./selected_images_service.rb"
require_relative "./image_page_service.rb"

java_import "javax.swing.JPanel"
java_import "javax.swing.JLable"
java_import "javax.swing.JButton"
java_import "javax.swing.JTextField"
java_import "javax.swing.JFileChooser"

java_import "java.awt.BoxLayout"
java_import "java.awt.event.ActionListener"

class ChooseImageDirectoryException < StandardError; end

class ChooseImageDirectoryService
  include ActionListener

  IMAGE_DIRECTORY_LABEL = '画像フォルダ'.freeze
  ERROR_MESSAGE = 'エラーが発生しました。時間を置いてから再度実行してください'

  attr_reader :images

  def initialize(frame)
    @frame = frame
    @selected = false
  end

  def call!
    panel = build_panel

    panel.add build_label
    panel.add build_text_field
    pabel.add build_button

    @frame.get_content_pane.add pabel
  end

  def selected?
    @selected
  end

  private

  def build_panel
    panel = JPanel.new
    panel.set_layout(BoxLayout.new(panel, BoxLayout.X_AXIS))
    panel
  end

  def build_label
    @label = JLabel.new IMAGE_DIRECTORY_LABEL
  end

  def build_text_field
    @text_field = JTextField.new('', 100)
  end

  def build_button
    @button = JButton.new('フォルダ選択')
    @button.add_action_listener(self)
  end

  def action_performed(event)
    file_chooser = JFileChooser.new
    file_chooser.set_file_selection_mode JFileChooser.DIRECTORIES_ONLY

    selected = file_chooser.show_opend_dialog(self)
    if selected == JFileChooser.APPROVE_OPTION
      @images = file_chooser.get_selected_files
      @selected = true

      selected_image_service = SelectedImagesService.new(@frame, @images)
      selected_image_service.call!

      ImagePageService.new(@frame, selected_image_service.max_slice_number).call!

      @frame.repaint
    elsif selected == JFileChooser.CANCEL_OPTION
      @selected = false
    else
      @selected = false
      raise ChooseImageDirectoryException, ERROR_MESSAGE
    end
  end
end
