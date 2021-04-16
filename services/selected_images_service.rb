# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "../lib/table/button_column.rb"
require_relative "./base_service.rb"

java_import "javax.swing.JScrollPane"
java_import "javax.swing.JLable"
java_import "javax.swing.JButton"
java_import "javax.swing.JTable"
java_import "javax.swing.table.DefaultTableModel"
java_import "javax.swing.table.TableCellRenderer"

java_import "ij.ImagePlus"

java_import "loci.plugins.BF"
java_import "loci.plugins.in.ImporterOptions"

java_import "java.awt.event.ActionListener"

class SelectedImagesService < BaseService
  IMAGES_TABLE_COLUMN = ['画像名', ''].freeze
  RANGE_OPERATION_LABEL = '範囲指定'.freeze
  RANGE_OPERATION_COLUMN = 1

  attr_reader :max_slice_number

  def initialize(frame)
    super
    @frame = frame
    @max_slice_number = 0
  end

  def call!
    return unless @config.set_images?
    return unless @config.images.size == 0

    table_rows = @config.images.map do |image|
      [image.get_name, RANGE_OPERATION_LABEL]
    end

    model = DefaultTableModel.new table_rows, IMAGES_TABLE_COLUMN
    table = JTable.new model

    panel = JScrollPane.new table

    button_column = ButtonColumn.new(table, RANGE_OPERATION_COLUMN, RangeButtonActionListener.new)

    @panel.add table
    @frame.get_content_pane.add @panel
  end

  class RangeButtonActionListener
    include ActionListener

    def action_performed(event)
      table = event.get_source
      row = event.get_action_command.to_i

      image_file = table.get_value_at(row - 1, RANGE_OPERATION_COLUMN)
      bio_formats_options = bio_formats_options image_file

      imps = BF.open_image_plus(bio_formats_options)
      imps.each do |imp|
        stack_number = imp.get_image_stack_size
        @config.max_slice_number = stack_number if @max_slice_number < stack_number
        imp.show
      end
    end

    private

    def bio_formats_options(image_path)
      options = ImporterOptions.new
      options.set_id @image_path
      options.set_autoscale true
      options
    end
  end
end
