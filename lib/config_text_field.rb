require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "../lib/text_field_changed_listener.rb"

java_import "javax.swing.JTextField"

class ConfigTextField < JTextField
  def initialize(config_name, placeholder = '', column_count = 100)
    super placeholder, column_count
    @config_name = config_name

    self.get_document.add_document_listener(TextFieldChangedListener.new(self, @config_name))
  end
end