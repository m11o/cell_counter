# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

require_relative "../lib/table/button_column.rb"

java_import "javax.swing.JScrollPane"
java_import "javax.swing.JLable"
java_import "javax.swing.JButton"
java_import "javax.swing.JTable"
java_import "javax.swing.table.DefaultTableModel"
java_import "javax.swing.table.TableCellRenderer"

java_import "ij.plugin.ContrastEnhancer"
java_import "ij.ImagePlus"

java_import "loci.plugins.BF"
java_import "loci.plugins.in.ImporterOptions"

java_import "java.awt.event.ActionListener"

class SelectedImagesService
  IMAGES_TABLE_COLUMN = ['画像名', ''].freeze
  RANGE_OPERATION_LABEL = '範囲指定'.freeze
  RANGE_OPERATION_COLUMN = 1

  def initialize(frame, images = [])
    @frame = frame
    @images = images
  end

  def call!
    table_rows = @images.map do |image|
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

    def initialize
      @contrast_enhancer = ContrastEnhancer.new
    end

    def action_performed(event)
      table = event.get_source
      row = event.get_action_command.to_i

      image_file = table.get_value_at(row - 1, RANGE_OPERATION_COLUMN)
      bio_formats_options = bio_formats_options image_file

      imps = BF.open_image_plus(bio_formats_options)
      imps.each do |imp|
        stack_size = imp.get_image_stack_size
        (1..stack_size).each do |slice_number|
          imp.set_slice slice_number
          @contrast_enhancer.equalize(imp)
          @contrast_enhancer.stretchHistogram(imp, 0.3)
        end
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
