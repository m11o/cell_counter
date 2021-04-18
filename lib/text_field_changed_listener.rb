require_relative "./config_store"

java_import "javax.swing.event.DocumentListener"

class TextFieldChangedListener
  include DocumentListener

  def initialize(text_field, config_attribute)
    @text_field = text_field
    @config_attribute = config_attribute
    @config = ConfigStore.instance
  end

  def changed_update(_event)
    self.value = @text_field.get_text
  end

  def remove_update(_event)
    self.value = @text_field.get_text
  end

  def insert_update(_event)
    self.value = @text_field.get_text
  end

  private

  def value=(value)
    @config.send("#{@config_attribute}=", value)
  end
end
