# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"
require "singleton"

java_import "fiji.util.gui.GenericDialogPlus"

class ChooseImageDirectory
  include Singleton

  DIALOG_TITLE = "Choose Image Directory".freeze
  CHOOSE_IMAGE_LABEL = "画像ディレクトリ指定".freeze
  
  def run
    gui = GenericDialogPlus.new DIALOG_TITLE
    gui.add_directory_field(CHOOSE_IMAGE_LABEL, "")
    gui.show_dialog

    return gui.get_next_string if gui.was_oked

    raise
  end
end