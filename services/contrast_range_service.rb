# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

java_import "javax.swing.JPanel"
java_import "javax.swing.JLable"
java_import "javax.swing.JTextField"
java_import "javax.swing.BoxLayout"
java_import "javax.swing.event.DocumentListener"

java_import "java.awt.event.ActionListener"

class ContrastRangeService
  MAX_TEXT_FIELD_COUNT = 10

  def initialize(frame)
    @frame = frame
  end

  def call!
    panel = build_panel

    panel.add build_label('コントラスト')

    min_contrast_textfield = build_text_field(:contrast_min, 'min')
    panel.add min_contrast_textfield

    panel.add build_label(' - ')

    max_contrast_textfield = build_text_field(:contrast_max, 'max')
    panel.add max_contrast_textfield

    @frame.get_content_pane.add panel
  end

  private

  def build_panel
    panel = JPanel.new
    panel.set_layout(BoxLayout.new(panel, BoxLayout.X_AXIS))
    panel
  end

  def build_label(label_value)
    JLable.new(label_value)
  end

  def build_text_field(config_attribute, place_holder = '')
    text_field = JTextField.new place_holder, MAX_TEXT_FIELD_COUNT

    action = ContrastDocumentListener.new(text_field, config_attribute)
    text_field.get_document.add_document_listener(action)
    text_field
  end

  class ContrastDocumentListener
    include DocumentListener

    def initialize(text_field, config_attribute)
      @text_field = text_field
      @config_attribute = config_attribute
      @config = Config.instance
    end

    def changed_update
      self.contrast_value = text_field.get_text
    end

    def remove_update
      self.contrast_value = text_field.get_text
    end

    def insert_update
      self.contrast_value = text_field.get_text
    end

    private

    def contrast_value=(value)
      @config.send("#{@config_attribute}=", value)
    end
  end
end