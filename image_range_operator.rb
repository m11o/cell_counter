# @AppService appService
require_relative "#{$appService.getApp.getBaseDirectory}/plugins/JRuby/imagej.rb"

java_import "javax.swing.JFrame"
java_import "javax.swing.JPanel"
java_import "javax.swing.JLabel"
java_import "java.awt.FlowLayout"
java_import "javax.swing.ScrollPaneLayout"
java_import "javax.swing.JButton"
java_import "java.awt.event.ActionListener"
java_import "ij.plugin.frame.RoiManager"
java_import "ij.IJ"
java_import "ij.ImagePlus"
java_import "ij.plugin.ContrastEnhancer"
java_import "loci.plugins.BF"
java_import "loci.plugins.in.ImporterOptions"

class ImageRangeOperator
  DIALOG_TITLE = "画像の範囲指定"

  def initialize(image_dir)
    @image_dir = image_dir
    @frame = JFrame.new DIALOG_TITLE
    @roi_manager = RoiManager.getRoiManager
  end

  def run
    # @frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE)
    @frame.set_bounds(10, 10, 400, 300)
    @frame.set_layout(ScrollPaneLayout.new)
    build_image_list
    @frame.set_visible(true)
  end

  private

  def build_image_list
    Dir.glob("#{@image_dir}/*") do |image_path|
      puts image_path
      panel = build_image_item image_path
      @frame.get_content_pane.add panel
    end
  end

  def build_image_item(image_path)
    panel = JPanel.new(FlowLayout.new)
    
    label = JLabel.new image_name(image_path)
    panel.add label

    button = JButton.new "範囲指定"
    panel.add button
    button.add_action_listener(ImageRangeButtonListener.new(image_path, @roi_manager))
    panel
  end

  def image_name(image_path)
    File.basename(image_path)
  end

  class ImageRangeButtonListener
    include ActionListener
    
    def initialize(image_path, roi_manager)
      @image_path = image_path
      @roi_manager = roi_manager
      @contrast_enhancer = ContrastEnhancer.new

      @bio_formats_options = bio_formats_options image_path
    end

    def action_performed(event)
      imps = BF.open_image_plus(@bio_formats_options)
      imps.each do |imp|
        @contrast_enhancer.equalize(imp)
        @contrast_enhancer.stretchHistogram(imp, 0.3)
        imp.show

        window = imp.get_window
        puts window.inspect
        puts window.isFocusableWindow
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