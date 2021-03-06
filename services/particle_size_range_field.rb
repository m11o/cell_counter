require_relative "./minmax_field"

class ParticleSizeRangeField < MinmaxField
  set_constraints_position 1, 1, 1, 1
  set_padding_insets 5, 10, 0, 10

  def initialize(frame)
    super frame, "particle size\n(area)(μm^2)", :particle_size_min, :particle_size_max
  end
end
