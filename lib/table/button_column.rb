# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

java_import "javax.swing.JButton"

java_import "javax.swing.table.TableCellRenderer"
java_import "javax.swing.table.TableCellEditor"
java_import "javax.swing.AbstractCellEditor"
java_import "javax.swing.UIManager"

java_import "java.awt.event.ActionListener"
java_import "java.awt.event.MouseListener"
java_import "java.awt.event.ActionEvent"

class ButtonColumn
  include TableCellRenderer
  include ActionListener
  include MouseListener

  def initialize(table, column, action)
    @table = table
    @action = action

    @button = JButton.new

    column_model = table.get_column_model
    column_model.get_column(column).set_cell_renderer(self)
    @table.add_mouse_listener(self)
  end

  def getTableCellRendererComponent(table, value, is_selected, has_focus, row, column)
    @button.set_text(value.to_s)
    @button.set_icon(nil)
    @button
  end

  def action_performed(event)
    @action.action_performed(event)
  end
end
