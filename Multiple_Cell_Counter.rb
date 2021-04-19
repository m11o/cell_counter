java_import "javax.swing.JFrame"
java_import "javax.swing.JPanel"
java_import "javax.swing.JFileChooser"
java_import "javax.swing.JTable"
java_import "javax.swing.JButton"
java_import "javax.swing.JComboBox"
java_import "javax.swing.JProgressBar"
java_import "javax.swing.JDialog"
java_import "javax.swing.JSpinner"
java_import "javax.swing.SpinnerNumberModel"

java_import "javax.swing.event.ChangeListener"

java_import "javax.swing.table.TableCellRenderer"

java_import "java.awt.GridBagLayout"
java_import "java.awt.GridBagConstraints"
java_import "java.awt.Insets"
java_import "java.awt.BorderLayout"

java_import "java.awt.event.ActionListener"
java_import "java.awt.event.ItemListener"
java_import "java.awt.event.ItemEvent"

java_import "loci.plugins.BF"
java_import "loci.plugins.in.ImporterOptions"


# =============================================================================
# ConfigStore
# =============================================================================
require 'singleton'

class ConfigStore
  include Singleton

  COLUMN = %i[
    image_dir images page_number max_slice_number
    contrast_min contrast_max threshold_min threshold_max particle_size_min particle_size_max
  ]

  attr_accessor *COLUMN

  def set?(column_name)
    return false unless COLUMN.include? column_name.to_sym

    !send(column_name).nil?
  end

  def method_missing(name, *args)
    return super if name !~ /\Aset_(.+?)\?\z/

    column_name = Regexp.last_match[1].to_sym
    return super unless COLUMN.include? column_name

    set? column_name
  end

  def unset_attributes
    COLUMN.select { |column_name| !set? column_name }
  end

  def all?
    COLUMN.all? { |column_name| set?(column_name) }
  end

  module Helper
    def config
      @config ||= ConfigStore.instance
    end
  end
end

# =============================================================================
# ComponentOperator
# =============================================================================
module ComponentOperator
  def self.add_component_with_constraints(panel, layout, constraints, grid_x, grid_y, grid_width, grid_height, anchor = anchor_west, &block)
    constraints.gridx = grid_x
    constraints.gridy = grid_y
    constraints.gridwidth = grid_width
    constraints.gridheight = grid_height
    constraints.anchor = anchor

    component = block.call constraints
    layout.set_constraints component, constraints
    panel.add component
  end

  def self.method_missing(name, *args)
    super if name !~ /\Aanchor_(.+?)\z/

    const_name = Regexp.last_match[1].upcase
    GridBagConstraints.const_get const_name.to_sym
  end

  def self.build_padding_insets(top, left, bottom, right)
    Insets.new top, left, bottom, right
  end
end

# =============================================================================
# GridBagConstraintsBasePanel
# =============================================================================
class GridBagConstraintsBasePanel < JPanel
  include ConfigStore::Helper

  def initialize
    @layout = GridBagLayout.new
    @constraints = GridBagConstraints.new

    super @layout
  end

  def add_component_with_constraints(grid_x, grid_y, grid_width, grid_height, anchor = anchor_west, &block)
    ComponentOperator.add_component_with_constraints(self, @layout, @constraints, grid_x, grid_y, grid_width, grid_height, anchor, &block)
  end

  def build_padding_insets(top: 0, left: 0, bottom: 0, right: 0)
    ComponentOperator.build_padding_insets top, left, bottom, right
  end

  def method_missing(name, *args)
    super if name !~ /\Aanchor_(.+?)\z/

    ComponentOperator.send name
  end
end

# =============================================================================
# BioFormatHelper
# =============================================================================
module BioFormatHelper
  def get_image_plus_by_bf(image_path)
    BF.open_image_plus(bio_formats_options(image_path))
  end

  def bio_formats_options(image_path)
    options = ImporterOptions.new
    options.set_id image_path
    options.set_autoscale true
    options
  end
end

# =============================================================================
# GridBagConstraintsBasePanel
# =============================================================================
class ProgressBarDialog < JDialog
  def initialize(frame, max_count, min_count = 1)
    super frame, 'Progress Bar'

    @max_count = max_count
    @min_count = @current_count = min_count

    set_size 500, 300
    set_location_relative_to nil

    label = create_label
    @progress_bar = create_progress_bar

    get_content_pane.add(label)
    get_content_pane.add(@progress_bar)
    set_visible(true)
  end

  def processing(&block)
    block.call
    @current_count += 1
    @progress_bar.set_value @current_count

    dispose if @current_count >= @max_count
  end

  private

  def create_label
    label = JLabel.new 'Please wait ...'
    label.set_horizontal_alignment(JLabel::CENTER)
    label
  end

  def create_progress_bar
    progress_bar = JProgressBar.new @min_count, @max_count
    #progress_bar.set_string_painted true
    #progress_bar.set_string ''
    progress_bar.set_value 0
    progress_bar
  end
end

# =============================================================================
# ChooseImageDirectoryPanel
# =============================================================================
class ChooseImageDirectoryPanel < GridBagConstraintsBasePanel
  IMAGE_DIRECTORY_LABEL = '画像フォルダ'.freeze
  CHOOSE_DIRECTORY_BUTTON = 'フォルダ選択'.freeze

  attr_reader :frame

  def initialize(frame)
    super()
    @frame = frame

    add_component_with_constraints(0, 0, 1, 1) do |constraints|
      constraints.insets = build_padding_insets left: 10, right: 5, top: 10
      JLabel.new IMAGE_DIRECTORY_LABEL
    end
    add_component_with_constraints(1, 0, 1, 1) do
      button = JButton.new(CHOOSE_DIRECTORY_BUTTON)
      button.add_action_listener(ChooseImageDirectoryListener.new(self))
      button
    end
  end

  class ChooseImageDirectoryListener
    include ActionListener
    include BioFormatHelper
    include ConfigStore::Helper

    def initialize(panel)
      @panel = panel
    end

    def action_performed(_event)
      file_chooser = JFileChooser.new
      file_chooser.set_file_selection_mode JFileChooser::DIRECTORIES_ONLY

      selected = file_chooser.show_open_dialog(@panel.frame)
      if selected == JFileChooser::APPROVE_OPTION
        set_selected_images_information file_chooser.get_selected_file.get_path

        # selected image directory
        @panel.add_component_with_constraints(0, 1, 2, 1) do |constraints|
          constraints.insets = @panel.build_padding_insets left: 10, right: 10, bottom: 5
          JLabel.new config.image_dir
        end

        # page combo box
        @panel.add_component_with_constraints(0, 2, 1, 1) do |constraints|
          constraints.insets = @panel.build_padding_insets bottom: 5, left: 10, right: 5
          JLabel.new 'ページ指定'
        end
        @panel.add_component_with_constraints(1, 2, 1, 1) do |constraints|
          constraints.insets = @panel.build_padding_insets bottom: 5
          ImagePageComboBox.new
        end

        # selected image list in table
        @panel.add_component_with_constraints(0, 3, 2, @config.images.count + 1, @panel.anchor_center) { SelectedImagesTable.new }

        @panel.updateUI
        @panel.frame.pack
        @panel.frame.repaint
      elsif selected == JFileChooser::CANCEL_OPTION
        # 何もしない
      else
        raise
      end
    end

    def set_selected_images_information(image_dir)
      config.image_dir = image_dir

      processing_dialog = ProgressBarDialog.new @panel.frame, Dir.glob("#{image_dir}/*").count
      config.images = []
      config.max_slice_number = 1
      Dir.glob("#{image_dir}/*") do |image_path|
        config.images << image_path

        processing_dialog.processing do
          imps = get_image_plus_by_bf image_path
          imps.each do |imp|
            stack_number = imp.get_image_stack_size
            config.max_slice_number = stack_number if config.max_slice_number < stack_number
            imp.close
          end
        end
      end
    end
  end
end

# =============================================================================
# ImagePageComboBox
# =============================================================================
class ImagePageComboBox < JComboBox
  include ConfigStore::Helper

  WIDTH = 190.0

  def initialize
    super
    register_items
    update_size!

    add_item_listener ImagePageItemListener.new
  end

  private

  def register_items
    add_item ''
    add_item 'all'
    return unless config.set_max_slice_number?

    (1..config.max_slice_number).each { |page_number| add_item(page_number.to_s) }
  end

  def update_size!
    dimension = get_preferred_size
    height = dimension.get_height

    dimension.set_size WIDTH, height
    set_preferred_size dimension
  end

  class ImagePageItemListener
    include ConfigStore::Helper
    include ItemListener

    def item_state_changed(event)
      return if event.get_state_change != ItemEvent::SELECTED

      item = event.get_item
      config.page_number = item
    end
  end
end

# =============================================================================
# SelectedImagesTable
# =============================================================================
class SelectedImagesTable < JTable
  include ConfigStore::Helper

  IMAGES_TABLE_COLUMN = %w[画像名 操作]
  RANGE_OPERATION_LABEL = '範囲指定'.freeze
  RANGE_OPERATION_COLUMN = 1

  FILE_NAME_COLUMN_WIDTH = 280
  OPERATION_COLUMN_WIDTH = 80

  def initialize
    raise unless config.set_images?
    raise if config.images.size.zero?

    super table_rows.to_java(java.lang.String[]), IMAGES_TABLE_COLUMN.to_java
    update_table_column_width
  end

  private

  def table_rows
    config.images.map do |image_path|
      [File.basename(image_path), RANGE_OPERATION_LABEL]
    end
  end

  def update_table_column_width
    column_model = get_column_model
    filename_column = column_model.get_column(0)
    filename_column.set_preferred_width FILE_NAME_COLUMN_WIDTH

    operator_column = column_model.get_column(1)
    operator_column.set_preferred_width OPERATION_COLUMN_WIDTH
    convert_operation_button operator_column
  end

  def convert_operation_button(column_model)
    column_model.set_cell_renderer(OperationButtonColumnRenderer.new(RANGE_OPERATION_COLUMN))
  end

  class OperationButtonColumnRenderer
    include TableCellRenderer
    include ActionListener
    include BioFormatHelper

    def initialize(column_number)
      @column_number = column_number
    end

    def get_table_cell_renderer_component(_table, value, _is_selected, _has_focus, _row, _column)
      button = JButton.new
      button.set_text(value.to_s)
      button.set_icon(nil)
      button.add_action_listener(self)
      button
    end

    def action_performed(event)
      table = event.get_source
      row = event.get_action_command.to_i

      image_filename = table.get_value_at(row - 1, @column_number)

      imps = get_image_plus_by_bf "#{config.image_dir}/#{image_filename}"
      imps.each(&:show)
    end
  end
end

# =============================================================================
# ConfigSpinnerField
# =============================================================================
class ConfigSpinnerField < JSpinner
  MAX_VALUE = 9999999
  MIN_VALUE = 0

  def initialize(config_attribute, min = MIN_VALUE, max = MAX_VALUE, step = 1)
    model = SpinnerNumberModel.new 0, min, max, step
    super model

    add_change_listener ConfigSpinnerChangeListener.new(self, config_attribute)
  end

  class ConfigSpinnerChangeListener
    include ChangeListener
    include ConfigStore::Helper

    def initialize(spinner, config_attribute)
      @spinner = spinner
      @config_attribute = config_attribute
    end

    def state_changed(_event)
      config.send("#{@config_attribute}=", @spinner.get_value)
    end
  end
end

# =============================================================================
# MinmaxPanel
# =============================================================================
class MinmaxPanel < GridBagConstraintsBasePanel
  MAX_LABEL = '最大値'.freeze
  MIN_LABEL = '最小値'.freeze

  def initialize(title, min_field_name, max_field_name)
    super()

    @title = title
    @min_field_name = min_field_name
    @max_field_name = max_field_name

    add_component_with_constraints(0, 0, 1, 1) { JLabel.new nl2br(@title) }
    add_component_with_constraints(0, 1, 1, 1) { JLabel.new MIN_LABEL }
    add_component_with_constraints(1, 1, 1, 1) { ConfigSpinnerField.new @min_field_name }
    add_component_with_constraints(0, 2, 1, 1) { JLabel.new MAX_LABEL }
    add_component_with_constraints(1, 2, 1, 1) { ConfigSpinnerField.new @max_field_name }
  end

  private

  def nl2br(label)
    return label if label !~ /\n/

    converted_label = label.gsub(/\n/, '<br />')
    "<html><body>#{converted_label}</body></html>"
  end
end

# =============================================================================
# ExceptionDialog
# =============================================================================
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
    dialog.set_size 300, 200
    dialog.set_location_relative_to nil
    dialog.set_title('Error Log')

    label = JLabel.new @error_message
    label.set_horizontal_alignment(JLabel::CENTER)

    dialog.get_content_pane.add(label, 'Center')
    dialog.set_visible(true)
  end
end

# =============================================================================
# ImplementClickListener
# =============================================================================
class ImplementClickListener
  include ActionListener
  include ConfigStore::Helper

  def initialize(frame)
    @frame = frame
  end

  private

  def action_performed(_event)
    ExceptionDialog.call! @frame, error_message and return unless config.all?

    # TODO: セルカウントを実行
  end

  def error_message
    '<html><body>未設定のカラムが存在します。<br />確認の上、再度実行してください</body></html>'
  end
end


# =============================================================================
# Build Main Window
# =============================================================================
frame = JFrame.new 'Multiply Cell Counter'
begin
  layout = GridBagLayout.new
  constraints = GridBagConstraints.new
  pane = frame.get_content_pane
  pane.set_layout(layout)

  ComponentOperator.add_component_with_constraints(pane, layout, constraints, 0, 0, 2, 1) do
    ChooseImageDirectoryPanel.new(frame)
  end
  ComponentOperator.add_component_with_constraints(pane, layout, constraints, 0, 1, 1, 1) do |component_constraints|
    component_constraints.insets = ComponentOperator.build_padding_insets 5, 10, 0, 0
    MinmaxPanel.new('Contrast', :contrast_min, :contrast_max)
  end
  ComponentOperator.add_component_with_constraints(pane, layout, constraints, 0, 2, 2, 1) do |component_constraints|
    component_constraints.insets = ComponentOperator.build_padding_insets 0, 10, 5, 0
    MinmaxPanel.new('Threshold', :threshold_min, :threshold_max)
  end
  ComponentOperator.add_component_with_constraints(pane, layout, constraints, 1, 1, 1, 1) do |component_constraints|
    component_constraints.insets = ComponentOperator.build_padding_insets 5, 10, 0, 10
    MinmaxPanel.new("particle size\n(area)(μm^2)", :particle_size_min, :particle_size_max)
  end
  ComponentOperator.add_component_with_constraints(pane, layout, constraints, 1, 2, 1, 1, ComponentOperator.anchor_center) do
    button = JButton.new('実行')
    button.add_action_listener ImplementClickListener.new frame
    button
  end

  frame.pack
  frame.set_visible(true)
rescue => e
  puts e.message
  puts e.backtrace.join("\n")
  ExceptionDialog.new frame, 'エラーが発生しました'
end
