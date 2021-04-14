require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

java_import "javax.swing.JDialog"
java_import "javax.swing.JLabel"

class ExceptionDialog
  def self.call!(frame, message)
    new(frame, message).call!
  end

  def initialize(frame, message)
    @frame = frame
    @error_message = error_message
  end

  private

  def call!
    diablog = JDialog.new @frame
    label = JLabel.new @message

    diablog.get_content_pane.add(label, 'Center')
    diablog.pack
    diablog.set_visible(true)
  end
end