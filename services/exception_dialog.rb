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
    dialog.set_title('Error Log')
    label = JLabel.new @error_message

    dialog.get_content_pane.add(label, 'Center')
    dialog.pack
    dialog.set_visible(true)
  end
end
