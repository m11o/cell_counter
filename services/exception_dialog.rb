require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

java_import "javax.swing.JDialog"
java_import "javax.swing.JLabel"

class ExceptionDialog
  def self.call!(frame, message)
    new(frame, message).call!
  end

  def initialize(frame, message)
    @frame = frame
    @error_message = message
  end

  def call!
    dialog = JDialog.new @frame
    dialog.set_size 200, 150
    dialog.set_location_relative_to nil
    dialog.set_title('Error Log')

    label = JLabel.new @error_message
    label.set_horizontal_alignment(JLabel::CENTER)

    dialog.get_content_pane.add(label, 'Center')
    dialog.set_visible(true)
  end
end
